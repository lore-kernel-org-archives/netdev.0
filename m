From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Fwd: [patch] netfilter: ebt_ip6: regression bug fix
Date: Wed, 3 Jul 2013 11:19:09 -0700
Message-ID: <CA+55aFwUf2+nm5GQKkZsSPs9r3AGREH=shE3+3oVeiJ18jJC4Q@mail.gmail.com>
References: <51D46949.8080703@uolinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f182.google.com ([209.85.128.182]:48947 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932575Ab3GCSTK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 14:19:10 -0400
Received: by mail-ve0-f182.google.com with SMTP id ox1so411632veb.13
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 11:19:09 -0700 (PDT)
In-Reply-To: <51D46949.8080703@uolinc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

People send fixes to random places, and I forward them.. I'm feeling
very managerial today.

             Linus


---------- Forwarded message ----------
=46rom: Luis Fernando Cornachioni Estrozi <lestrozi@uolinc.com>
Date: Wed, Jul 3, 2013 at 11:11 AM
Subject: [patch] netfilter: ebt_ip6: regression bug fix
To: Bart De Schuymer <bdschuym@pandora.be>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>


=46rom: Lu=C3=ADs Fernando Estrozi <lestrozi@uolinc.com>

fix regression bug in ebt_ip6 which resulted in ebtables IPv6 src/dst
fields not being zeroed

Signed-off-by: Lu=C3=ADs Fernando Estrozi <lestrozi@uolinc.com>
---
this bug was introduced on commit
0898f99a267f89a7dc72cc687955f17613a711b8 on Mar 08, 2010; I'm just
returning 2 checks that existed before as suggested by Bart De Schuymer

--- linux-3.8.13/net/bridge/netfilter/ebt_ip6.c.orig    2013-07-03
12:07:25.892466692 -0300
+++ linux-3.8.13/net/bridge/netfilter/ebt_ip6.c    2013-07-03
12:29:47.272496246 -0300
@@ -48,10 +48,12 @@ ebt_ip6_mt(const struct sk_buff *skb, st
      if (info->bitmask & EBT_IP6_TCLASS &&
         FWINV(info->tclass !=3D ipv6_get_dsfield(ih6), EBT_IP6_TCLASS)=
)
          return false;
-    if (FWINV(ipv6_masked_addr_cmp(&ih6->saddr, &info->smsk,
-                       &info->saddr), EBT_IP6_SOURCE) ||
-        FWINV(ipv6_masked_addr_cmp(&ih6->daddr, &info->dmsk,
-                       &info->daddr), EBT_IP6_DEST))
+    if ((info->bitmask & EBT_IP6_SOURCE &&
+            FWINV(ipv6_masked_addr_cmp(&ih6->saddr, &info->smsk,
+                    &info->saddr), EBT_IP6_SOURCE)) ||
+            (info->bitmask & EBT_IP6_DEST &&
+            FWINV(ipv6_masked_addr_cmp(&ih6->daddr, &info->dmsk,
+                    &info->daddr), EBT_IP6_DEST)))
          return false;
      if (info->bitmask & EBT_IP6_PROTO) {
          uint8_t nexthdr =3D ih6->nexthdr;

________________________________

AVISO: A informa=C3=A7=C3=A3o contida neste e-mail, bem como em qualque=
r de seus
anexos, =C3=A9 CONFIDENCIAL e destinada ao uso exclusivo do(s)
destinat=C3=A1rio(s) acima referido(s), podendo conter informa=C3=A7=C3=
=B5es
sigilosas e/ou legalmente protegidas. Caso voc=C3=AA n=C3=A3o seja o
destinat=C3=A1rio desta mensagem, informamos que qualquer divulga=C3=A7=
=C3=A3o,
distribui=C3=A7=C3=A3o ou c=C3=B3pia deste e-mail e/ou de qualquer de s=
eus anexos =C3=A9
absolutamente proibida. Solicitamos que o remetente seja comunicado
imediatamente, respondendo esta mensagem, e que o original desta
mensagem e de seus anexos, bem como toda e qualquer c=C3=B3pia e/ou
impress=C3=A3o realizada a partir destes, sejam permanentemente apagado=
s
e/ou destru=C3=ADdos. Informa=C3=A7=C3=B5es adicionais sobre nossa empr=
esa podem ser
obtidas no site http://sobre.uol.com.br/.

NOTICE: The information contained in this e-mail and any attachments
thereto is CONFIDENTIAL and is intended only for use by the recipient
named herein and may contain legally privileged and/or secret
information.
If you are not the e-mail=C2=B4s intended recipient, you are hereby
notified that any dissemination, distribution or copy of this e-mail,
and/or any attachments thereto, is strictly prohibited. Please
immediately notify the sender replying to the above mentioned e-mail
address, and permanently delete and/or destroy the original and any
copy of this e-mail and/or its attachments, as well as any printout
thereof. Additional information about our company may be obtained
through the site http://www.uol.com.br/ir/.
