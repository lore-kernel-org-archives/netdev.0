From: Cong Wang <amwang@redhat.com>
Subject: Re: A regression introduced by 802.1ad support patches
Date: Sun, 21 Apr 2013 17:49:17 +0800
Message-ID: <1366537757.23100.11.camel@cr0>
References: <1366530184.23100.6.camel@cr0>
	 <20130421093436.GA26775@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab3DUJt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 05:49:27 -0400
In-Reply-To: <20130421093436.GA26775@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-04-21 at 11:34 +0200, Patrick McHardy wrote:
> commit 77734833d78bcf0a3f58cde8b5b2424e8fc8b7e6
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Sun Apr 21 11:34:12 2013 +0200
> 
>     net: vlan: fix memory leak in vlan_info_rcu_free()
>     
>     The following leak is reported by kmemleak:
>     
>     [   86.812073] kmemleak: Found object by alias at
> 0xffff88006ecc76f0
>     [   86.816019] Pid: 739, comm: kworker/u:1 Not tainted 3.9.0-rc5+
> #842
>     [   86.816019] Call Trace:
>     [   86.816019]  <IRQ>  [<ffffffff81151c58>] find_and_get_object
> +0x8c/0xdf
>     [   86.816019]  [<ffffffff8190e90d>] ? vlan_info_rcu_free
> +0x33/0x49
>     [   86.816019]  [<ffffffff81151cbe>] delete_object_full+0x13/0x2f
>     [   86.816019]  [<ffffffff8194bbb6>] kmemleak_free+0x26/0x45
>     [   86.816019]  [<ffffffff8113e8c7>] slab_free_hook+0x1e/0x7b
>     [   86.816019]  [<ffffffff81141c05>] kfree+0xce/0x14b
>     [   86.816019]  [<ffffffff8190e90d>] vlan_info_rcu_free+0x33/0x49
>     [   86.816019]  [<ffffffff810d0b0b>] rcu_do_batch+0x261/0x4e7
>     
>     The reason is that in vlan_info_rcu_free() we don't take the VLAN
> protocol
>     into account when iterating over the vlan_devices_array.
>     
>     Reported-by: Cong Wang <amwang@redhat.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net> 

Yes, indeed.

Tested-by: Cong Wang <amwang@redhat.com>
