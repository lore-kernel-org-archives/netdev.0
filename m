From: Patrick McHardy <kaber@trash.net>
Subject: Re: WARNING while bringing up macvlan
Date: Fri, 28 Mar 2008 16:00:40 +0100
Message-ID: <47ED0818.3030409@trash.net>
References: <20080328125409.M80978@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34898 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581AbYC1PAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 11:00:45 -0400
In-Reply-To: <20080328125409.M80978@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> To trigger just run:
> ip link add link eth0 eth2 type macvlan
> ip link set eth2 up
> 
> [ 1212.916818]  [<c0121038>] warn_on_slowpath+0x41/0x51
> [ 1212.916859]  [<c012f652>] ? __kernel_text_address+0x1b/0x27
> [ 1212.916895]  [<c010493a>] ? dump_trace+0xce/0xda
> [ 1212.916927]  [<c0109ea6>] ? save_stack_address+0x0/0x2c
> [ 1212.916965]  [<c013afc8>] ? mark_held_locks+0x41/0x5c
> [ 1212.916999]  [<c015cdef>] ? kmem_cache_alloc+0x69/0xa1
> [ 1212.917033]  [<c013b12d>] ? trace_hardirqs_on+0xcb/0x102
> [ 1212.917067]  [<c02ba549>] mutex_trylock+0x3c/0xef
> [ 1212.917099]  [<c0272796>] rtnl_trylock+0xd/0xf
> [ 1212.917131]  [<c0268bc8>] __dev_set_promiscuity+0x15/0xa9


This is a known harmless warning caused by ASSERT_RTNL calling
rtnl_trylock. To fix this we'd need to move multicast list
programming into process context. For now you can simply
ignore it.
