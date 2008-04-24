From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Slab Corruption with ipv6 and tcp6fuzz
Date: Fri, 25 Apr 2008 01:13:20 +0400
Message-ID: <20080424211320.GA13695@2ka.mipt.ru>
References: <20080424142727.GA24025@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35505 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752815AbYDXVNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 17:13:40 -0400
Content-Disposition: inline
In-Reply-To: <20080424142727.GA24025@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Apr 24, 2008 at 04:27:27PM +0200, Eric Sesterhenn (snakebyte@gmx.de) wrote:
> i found some local ivp6 network fuzzing tools from the bsd folks
> today and wanted to add them to my testmachine. When
> trying one of them (running with user privs) it gave me slab corruption errors.
> Running http://clem1.be/lf6/tcp6fuzz.c 1 to 5 times
> always results in errors, strangely using the same seed twice
> in a row doesnt trigger the warnings again.
> 
> If there is any more info i can provide please let me know.

$ wget http://clem1.be/lf6/tcp6fuzz.c
--01:09:26--  http://clem1.be/lf6/tcp6fuzz.c
           => `tcp6fuzz.c'
 Resolving clem1.be... 88.169.180.107
 Connecting to clem1.be|88.169.180.107|:80... failed: Connection refused.

Please post your source here (google can not find it either), if it is
that easily reproducible, you can be sure, bug will be fixed in a few
moments.

> [   57.810370] sock_set_timeout: `tcp6fuzz' (pid 3721) tries to set negative timeout
> [  215.102729] =============================================================================
> [  215.102786] BUG skbuff_head_cache: Invalid object pointer 0xccd2b520
> [  215.102810] -----------------------------------------------------------------------------
> [  215.102816] 
> [  215.102840] INFO: Slab 0xc119c560 used=10 fp=0x00000000 flags=0x40000083
> [  215.102868] Pid: 0, comm: swapper Not tainted 2.6.25-03562-g3dc5063 #23
> [  215.102880]  [<c0177b57>] slab_err+0x47/0x50
> [  215.102978]  [<c0177bc7>] ? slab_pad_check+0x67/0xe0
> [  215.102994]  [<c0177c92>] ? check_slab+0x52/0x80
> [  215.103010]  [<c0179405>] __slab_free+0x1d5/0x2d0
> [  215.103024]  [<c0179eb0>] kmem_cache_free+0x80/0xe0
> [  215.103039]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
> [  215.103063]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
> [  215.103078]  [<c05d91dc>] __kfree_skb+0x3c/0x90
> [  215.103090]  [<c05d9249>] kfree_skb+0x19/0x30
> [  215.103103]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0

So far can you run kernel with debug turned on and provide output of
gdb ./vmlinux
l *(tcp_v6_do_rcv+0x33b)

-- 
	Evgeniy Polyakov
