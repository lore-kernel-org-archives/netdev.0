From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange packet drops with heavy firewalling
Date: Tue, 13 Apr 2010 07:56:26 +0200
Message-ID: <1271138186.16881.168.camel@edumazet-laptop>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	 <q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>
	 <1271083479.2858.377.camel@ursa.amorsen.dk>
	 <p2x40c9f5b21004120833jd7a749cak6ea69cebd28f8352@mail.gmail.com>
	 <1271091990.2858.409.camel@ursa.amorsen.dk>
	 <u2y412e6f7f1004121618p6d6eff30q8a45a03faa59a912@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	zhigang gong <zhigang.gong@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59625 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab0DMF4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 01:56:33 -0400
Received: by bwz19 with SMTP id 19so92457bwz.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 22:56:31 -0700 (PDT)
In-Reply-To: <u2y412e6f7f1004121618p6d6eff30q8a45a03faa59a912@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 07:18 +0800, Changli Gao a =C3=A9crit :
> On Tue, Apr 13, 2010 at 1:06 AM, Benny Amorsen <benny+usenet@amorsen.=
dk> wrote:
> >
> >  99:         24    1306226          3          2   PCI-MSI-edge    =
  eth1-tx-0
> >  100:      15735    1648774          3          7   PCI-MSI-edge   =
   eth1-tx-1
> >  101:          8         11          9    1083022   PCI-MSI-edge   =
   eth1-tx-2
> >  102:          0          0          0          0   PCI-MSI-edge   =
   eth1-tx-3
> >  103:         18         15       6131    1095383   PCI-MSI-edge   =
   eth1-rx-0
> >  104:        217         32      46544    1335325   PCI-MSI-edge   =
   eth1-rx-1
> >  105:        154    1305595        218         16   PCI-MSI-edge   =
   eth1-rx-2
> >  106:         17         16       8229    1467509   PCI-MSI-edge   =
   eth1-rx-3
> >  107:          0          0          1          0   PCI-MSI-edge   =
   eth1
> >  108:          2         14         15    1003053   PCI-MSI-edge   =
   eth0-tx-0
> >  109:       8226    1668924        478        487   PCI-MSI-edge   =
   eth0-tx-1
> >  110:          3    1188874         17         12   PCI-MSI-edge   =
   eth0-tx-2
> >  111:          0          0          0          0   PCI-MSI-edge   =
   eth0-tx-3
> >  112:        203        185       5324    1015263   PCI-MSI-edge   =
   eth0-rx-0
> >  113:       4141    1600793        153        159   PCI-MSI-edge   =
   eth0-rx-1
> >  114:      16242    1210108        436       3124   PCI-MSI-edge   =
   eth0-rx-2
> >  115:        267       4173      19471    1321252   PCI-MSI-edge   =
   eth0-rx-3
> >  116:          0          1          0          0   PCI-MSI-edge   =
   eth0
> >
> >
> > irqbalanced seems to have picked CPU1 and CPU3 for all the interrup=
ts,
> > which to my mind should cause the same problem as before (where CPU=
1 and
> > CPU3 was handling all packets). Yet the box clearly works much bett=
er
> > than before.
>=20
> irqbalanced? I don't think it can work properly. Try RPS in netdev an=
d
> linux-next tree, and if cpu load isn't even, try this patch:
> http://patchwork.ozlabs.org/patch/49915/ .
>=20
>=20

Dont try RPS on multiqueue devices !

If number of queues matches CPU numbers, it brings nothing but extra
latencies !

Benny, I am not sure your irqbalance is up2date with multiqueue devices=
,
you might need to disable it and manually irqaffine each interrupt

echo 01 >/proc/irq/100/smp_affinity
echo 02 >/proc/irq/101/smp_affinity
echo 04 >/proc/irq/102/smp_affinity
echo 08 >/proc/irq/103/smp_affinity
echo 10 >/proc/irq/104/smp_affinity
echo 20 >/proc/irq/105/smp_affinity
echo 40 >/proc/irq/106/smp_affinity
echo 80 >/proc/irq/107/smp_affinity

echo 01 >/proc/irq/108/smp_affinity
echo 02 >/proc/irq/109/smp_affinity
echo 04 >/proc/irq/110/smp_affinity
echo 08 >/proc/irq/111/smp_affinity
echo 10 >/proc/irq/112/smp_affinity
echo 20 >/proc/irq/113/smp_affinity
echo 40 >/proc/irq/114/smp_affinity
echo 80 >/proc/irq/115/smp_affinity


