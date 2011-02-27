From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Sun, 27 Feb 2011 16:14:39 +0100
Message-ID: <4D6A6A5F.4030707@free.fr>
References: <20110221150710.GA5651@nord.niifaq.ru> <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru> <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lxc-users@lists.sourceforge.net, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Andrian Nord <nightnord@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:38698 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076Ab1B0POt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Feb 2011 10:14:49 -0500
In-Reply-To: <20110223170512.GA10277@nord.niifaq.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2011 06:13 PM, Andrian Nord wrote:
> On Mon, Feb 21, 2011 at 05:07:31PM +0100, Daniel Lezcano wrote:
>> I Cc'ed the netdev mailing list and Patrick in case my analysis is wrong
>> or incomplete.
> I'm confirming, that this happens only when macvlan's are onto dummy net
> device. In case of some physical interface under macvlan there is no lost
> packages and no broken checksums.

I did some tests with a 2.6.35 kernel version and it seems the checksum 
errors do not appear.
I noticed there are some changes in the dummy setup function:

   dev->features   |= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
   dev->features   |= NETIF_F_NO_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;


May be that was introduced by commit:

commit 6d81f41c58c69ddde497e9e640ba5805aa26e78c
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Sep 27 20:50:33 2010 +0000

     dummy: percpu stats and lockless xmit

     Converts dummy network device driver to :

     - percpu stats

     - 64bit stats

     - lockless xmit (NETIF_F_LLTX)

     - performance features added (NETIF_F_SG | NETIF_F_FRAGLIST |
     NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA)

     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>


Eric,

Andrian is observing, with a couple of macvlan (in bridge mode) on top 
of a dummy interface, a lot of checksums error and packets drop.
Each macvlan is in a different network namespace and the dummy interface 
is in the init_net.

Any ideas ?



