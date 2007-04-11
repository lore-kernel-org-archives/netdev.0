From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Wed, 11 Apr 2007 09:47:40 -0700
Message-ID: <20070411094740.e7c04b49.akpm@linux-foundation.org>
References: <200704110937.l3B9b1Kp001053@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: milan.kocian@wq.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52100 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753309AbXDKQrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 12:47:48 -0400
In-Reply-To: <200704110937.l3B9b1Kp001053@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Apr 2007 02:37:01 -0700 bugme-daemon@bugzilla.kernel.org wrote:

> 
> http://bugzilla.kernel.org/show_bug.cgi?id=8320
> 
>            Summary: replacing route in kernel doesn't send netlink message
>     Kernel Version: 2.6.20.6
>             Status: NEW
>           Severity: low
>              Owner: shemminger@osdl.org
>          Submitter: milan.kocian@wq.cz
> 
> 
> Most recent kernel where this bug did *NOT* occur: I think all 2.6 kernels
> Distribution: Debian (with vanilla kernel)
> Hardware Environment: PC
> Software Environment: Debian
> Problem Description:
> When you replace route (via ip r r ), no netlink message is sent. Or is it feature?
> 
> Steps to reproduce:
> 1. run 'ip monitor all' on one console
> 2. do 'ip r r EXISTING_ROUTE via DST' on second console
> 3. no message on console one
> 
> Small patch for fib_hash (tested) but use carefully I am newbie :-) :
> 
> --- fib_hash.c.old      2007-04-11 10:39:34.895667672 +0200
> +++ fib_hash.c  2007-04-11 10:41:34.623466280 +0200
> @@ -457,6 +457,8 @@
>                         fib_release_info(fi_drop);
>                         if (state & FA_S_ACCESSED)
>                                 rt_cache_flush(-1);
> +                       rtmsg_fib(RTM_NEWROUTE, key, fa, cfg->fc_dst_len, tb->tb_id,
> +                                 &cfg->fc_nlinfo);
>                         return 0;
>                 }
> 
> And for fib_trie (not tested):
> 
> --- fib_trie.c.old      2007-04-11 10:39:22.728517360 +0200
> +++ fib_trie.c  2007-04-11 10:40:40.778651936 +0200
> @@ -1205,6 +1205,8 @@
>                         fib_release_info(fi_drop);
>                         if (state & FA_S_ACCESSED)
>                                 rt_cache_flush(-1);
> +                       rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
> +                                 &cfg->fc_nlinfo);
> 
>                         goto succeeded;
>                 }

Thanks.  We prefer to receive patches via email rather than via bugzilla. 
But that's a relatively minor matter - let's see what the net guys think
about the change first ;)

