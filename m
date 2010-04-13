From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Strange packet drops with heavy firewalling
Date: Tue, 13 Apr 2010 15:39:06 +0200
Message-ID: <4BC473FA.6020903@itcare.pl>
References: <m339z50x1l.fsf@ursa.amorsen.dk>	 <q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>	 <1271083479.2858.377.camel@ursa.amorsen.dk>	 <p2x40c9f5b21004120833jd7a749cak6ea69cebd28f8352@mail.gmail.com>	 <1271091990.2858.409.camel@ursa.amorsen.dk>	 <u2y412e6f7f1004121618p6d6eff30q8a45a03faa59a912@mail.gmail.com>	 <4BC464A6.9000307@itcare.pl> <1271163184.16881.307.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	zhigang gong <zhigang.gong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:39724 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017Ab0DMNjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 09:39:10 -0400
In-Reply-To: <1271163184.16881.307.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-04-13 14:53, Eric Dumazet pisze:
> Le mardi 13 avril 2010 =C3=A0 14:33 +0200, Pawe=C5=82 Staszewski a =C3=
=A9crit :
>   =20
>> W dniu 2010-04-13 01:18, Changli Gao pisze:
>>     =20
>>> On Tue, Apr 13, 2010 at 1:06 AM, Benny Amorsen<benny+usenet@amorsen=
=2Edk>   wrote:
>>>
>>>       =20
>>>>    99:         24    1306226          3          2   PCI-MSI-edge =
     eth1-tx-0
>>>>    100:      15735    1648774          3          7   PCI-MSI-edge=
      eth1-tx-1
>>>>    101:          8         11          9    1083022   PCI-MSI-edge=
      eth1-tx-2
>>>>    102:          0          0          0          0   PCI-MSI-edge=
      eth1-tx-3
>>>>    103:         18         15       6131    1095383   PCI-MSI-edge=
      eth1-rx-0
>>>>    104:        217         32      46544    1335325   PCI-MSI-edge=
      eth1-rx-1
>>>>    105:        154    1305595        218         16   PCI-MSI-edge=
      eth1-rx-2
>>>>    106:         17         16       8229    1467509   PCI-MSI-edge=
      eth1-rx-3
>>>>    107:          0          0          1          0   PCI-MSI-edge=
      eth1
>>>>    108:          2         14         15    1003053   PCI-MSI-edge=
      eth0-tx-0
>>>>    109:       8226    1668924        478        487   PCI-MSI-edge=
      eth0-tx-1
>>>>    110:          3    1188874         17         12   PCI-MSI-edge=
      eth0-tx-2
>>>>    111:          0          0          0          0   PCI-MSI-edge=
      eth0-tx-3
>>>>    112:        203        185       5324    1015263   PCI-MSI-edge=
      eth0-rx-0
>>>>    113:       4141    1600793        153        159   PCI-MSI-edge=
      eth0-rx-1
>>>>    114:      16242    1210108        436       3124   PCI-MSI-edge=
      eth0-rx-2
>>>>    115:        267       4173      19471    1321252   PCI-MSI-edge=
      eth0-rx-3
>>>>    116:          0          1          0          0   PCI-MSI-edge=
      eth0
>>>>
>>>>
>>>> irqbalanced seems to have picked CPU1 and CPU3 for all the interru=
pts,
>>>> which to my mind should cause the same problem as before (where CP=
U1 and
>>>> CPU3 was handling all packets). Yet the box clearly works much bet=
ter
>>>> than before.
>>>>
>>>>         =20
>>> irqbalanced? I don't think it can work properly. Try RPS in netdev =
and
>>> linux-next tree, and if cpu load isn't even, try this patch:
>>> http://patchwork.ozlabs.org/patch/49915/ .
>>>
>>>
>>>
>>>       =20
>> Yes without irqbalance - and with irq affinity set by hand router wi=
ll
>> work much better.
>>
>> But I don't think that RPS will help him - I make some tests with RP=
S
>> and AFFINITY - results in attached file.
>> Test router make traffic management (hfsc) for almost 9k users
>>     =20
> Thanks for sharing Pawel.
>
> But obviously you are mixing apples and oranges.
>
>   Are you aware that HFSC and other trafic shapers do serialize acces=
s to
> data structures ? If many cpus try to access these structures in //, =
you
> have a lot of cache line misses. HFSC is a real memory hog :(
>
>   =20
Thanks Eric for explanation why RPS is useless for traffic management=20
routers.

> Benny do have firewalling (highly parallelized these days, iptables w=
as
> well improved in this area), but no traffic control.
>
>   =20
Hmm so maybe better choice for traffic management is use iptables for=20
"filter classification" instead of "u32 filters"- something like=20
iptables CLASSIFY target

> Anyway, Benny has now multiqueue devices, and therefore RPS will not
> help him. I suggested RPS before his move to multiqueue, and multique=
ue
> is the most sensible way to improve things, when no central lock is
> used. Every cpu can really work in //.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   =20

