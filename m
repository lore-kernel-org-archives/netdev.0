From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Fw: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Mon, 12 Mar 2007 11:24:03 +0100
Message-ID: <20070312102403.GB1664@ff.dom.local>
References: <20070222134918.e2f1af6d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, snakebyte@gmx.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:36905 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965485AbXCLKTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 06:19:53 -0400
Content-Disposition: inline
In-Reply-To: <20070222134918.e2f1af6d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22-02-2007 22:49, Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Thu, 22 Feb 2007 07:56:27 -0800
> From: bugme-daemon@bugzilla.kernel.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=8057
> 
>            Summary: slab corruption running ip6sic
>     Kernel Version: 2.6.21-rc1
>             Status: NEW
>           Severity: normal
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: snakebyte@gmx.de
> 
> 
> Most recent kernel where this bug did *NOT* occur: unknown
> Distribution: gentoo
> Hardware Environment: AMD-K6, 400MHz, 288MB Ram
> Software Environment: ip6sic (http://ip6sic.sourceforge.net/)
> Problem Description:
> 
> When running ip6sic against the loopback interface i get the following kernel
> messages:
> 
> [  199.514486] Slab corruption: start=d0505554, len=156
> [  199.514704] Redzone: 0x5a2cf071/0x5a2cf071.
> [  199.514859] Last user: [<c0465813>](kfree_skbmem+0x33/0x80)
...

>From bugzilla:
...
> Is it possible that the handler frees the skb even if it is not supposed to do so?
> 
> 
> ------- Additional Comment #14 From Eric Sesterhenn 2007-02-28 04:33 -------
> 
> the ipcomp handler is xfrm6_rcv(), which calls xfrm6_rcv_spi(), which contrary
> to all other handlers returns -1 instead of 0 after calling kfree_skb() on the
> skb. Changing the return value to 0 in xfrm6_input.c:xfrm6_rcv_spi() fixes the
> problem.
> But I got no clue at all if this would be a correct fix

I think your diagnose is correct (all "return -1" should be
changed to "return 0" in xfrm6_input.c).

Regards,
Jarek P.
