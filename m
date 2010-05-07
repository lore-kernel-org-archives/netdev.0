From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: VLAN I/F's and TX queue.
Date: Fri, 7 May 2010 10:04:54 +0200
Message-ID: <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:37074 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754158Ab0EGIJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 04:09:10 -0400
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id 07BD92597DD
	for <netdev@vger.kernel.org>; Fri,  7 May 2010 10:09:08 +0200 (CEST)
In-Reply-To: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund/Transmode wrote on 2010/05/03 13:34:28:
>
> We noted dropped pkgs on our VLAN interfaces and i stated to look
> for a cause. Here is a ifconfig example:
>
> eth0      Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:8886910 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:8880219 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:100
>           RX bytes:1626842951 (1.5 GiB)  TX bytes:1555540810 (1.4 GiB)
>
> eth0.1    Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:2161943 errors:0 dropped:98 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:2467090557 (2.2 GiB)  TX bytes:2480246455 (2.3 GiB)
>
> eth0.1.1  Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:2161943 errors:0 dropped:98 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:2458437901 (2.2 GiB)  TX bytes:2471598683 (2.3 GiB)
>
> Here I note that txqueuelen is 0 for eth0.1/eth0.1.1 and 100 for eth0 and
> that it is only eth0.1 and eth0.1.1 that drops pkgs. It feels as if eth0.1
> bypasses eth0's tx queue and passes pkgs directly to the HW driver. Is that so?
> If so, that feels a bit strange and I am not sure how to best
> fix this. Any ides?
>
> Using kernel 2.6.33

So I did some more testing
two nodes A and B connected over a slow link.
Create two VLAN's as above and start pinging from A to B
with pkg size 9600, start a few(4-10) parallel ping processes.

Now I see dropped packages on B, the receiver of pings, and no
pkg loss on A.

1) since the link is symmetrical, why do I only see pkg loss
   at B?

2) pkg loss in B only manifests on the VLAN's interfaces and
   always in pair as if one lost pkg is counted twice?

3) I would expect lost pkgs to be accounted on eth0 instead of
   the VLAN interface(s) since that is where the pkg is lost, why
   isn't it so?

    Jocke

