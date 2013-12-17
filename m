From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 net-next 0/7] pktgen IPsec support
Date: Tue, 17 Dec 2013 10:22:56 +0800
Message-ID: <52AFB580.5060403@windriver.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com> <52AEF4ED.4020504@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<hadi@cyberus.ca>, <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47419 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab3LQCXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 21:23:06 -0500
In-Reply-To: <52AEF4ED.4020504@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8816=E6=97=A5 20:41, Jamal Hadi Salim wrote:
> On 12/15/13 02:57, Fan Du wrote:
>> Hi, Dave
>>
>> Current pktgen IPsec supports only transport/ESP combinnation,
>> This patchset enables user to do almost any IPsec transformation,
>> both transport/tunnel mode, and AH/ESP/IPcomp type.
>>
>> Below configuration has been tested, and using Wireshark could decry=
pt
>> out plain text in good formation without any checksum/auth errors:
>>
>> Mode/TYPE   AH  ESP
>> Transport   x   x
>> Tunnel      x   x
>>
>
> Very nice - but i couldnt see which patch added the option to enable
> checksums.

I thought we have reach the consensus on this part in previous discussi=
on
(http://www.spinics.net/lists/netdev/msg261411.html), This enhancement
patch didn't change original behavior, nor does remove original impleme=
ntation.

This enhancement expects good encapsulation format for the receiver to
de-encapsulation.

If there is a need to play bad with IP checksum, I will do this in a di=
fferent
patchset, as bad checksum IP packet(with or without IPsec) got discarde=
d
at IP layer, and a generic pktgen option should be created for this fea=
ture.

> I also think that some dose of update to the pktgen documentation in
> Documents/  would be useful.

This is snippets of doc updates I could come up with. Please check if i=
t's ok
for you.

@@ -108,7 +108,9 @@ Examples:
                                MPLS_RND, VID_RND, SVID_RND
                                QUEUE_MAP_RND # queue map random
                                QUEUE_MAP_CPU # queue map mirrors smp_p=
rocessor_id()
+                              IPSEC # Make IPsec encapsulation for pac=
ket

+ pgset spi SPI_VALUE     Set specific SA used to transform packet.

   pgset "udp_src_min 9"   set UDP source port min, If < udp_src_max, t=
hen
                           cycle through the port range.
@@ -177,6 +179,18 @@ Note when adding devices to a specific CPU there g=
ood idea to also assign
  /proc/irq/XX/smp_affinity so the TX-interrupts gets bound to the same=
 CPU.
  as this reduces cache bouncing when freeing skb's.

+Enable IPsec
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+Default IPsec transformation with ESP encapsulation plus Transport mod=
e
+could be enabled by simply setting:
+
+pgset "flag IPSEC"
+pgset "flows 1"
+
+To avoid breaking existing testbed scripts for using AH type and tunne=
l mode,
+user could use "pgset spi SPI_VALUE" to specify which formal of transf=
ormation
+to employ.
+

  Current commands and configuration options
  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
@@ -225,6 +239,7 @@ flag
    UDPDST_RND
    MACSRC_RND
    MACDST_RND
+  IPSEC

  dst_min


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
