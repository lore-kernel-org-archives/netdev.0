From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 8/8] ipv6: add documentation for stable_secret, idgen_delay and idgen_retries knobs
Date: Mon, 23 Mar 2015 18:02:02 +0100
Message-ID: <6da46ae2f76bf9aca41bd09ea7f284b75955637c.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:42029 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753226AbbCWRCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:02:16 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 984912094D
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 13:02:13 -0400 (EDT)
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 6c07c2b..6825247 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1220,6 +1220,17 @@ anycast_src_echo_reply - BOOLEAN
 	FALSE: disabled
 	Default: FALSE
=20
+idgen_delay - INTEGER
+	Controls the delay in seconds after which time to retry
+	privacy stable address generation if a DAD conflict is
+	detected.
+	Default: 1 (as specified in RFC7212)
+
+idgen_retries - INTEGER
+	Controls the number of retries to generate a stable privacy
+	address if a DAD conflict is detected.
+	Default: 3 (as specified in RFC7212)
+
 mld_qrv - INTEGER
 	Controls the MLD query robustness variable (see RFC3810 9.1).
 	Default: 2 (as specified by RFC3810 9.1)
@@ -1540,6 +1551,20 @@ use_optimistic - BOOLEAN
 		0: disabled (default)
 		1: enabled
=20
+stable_secret - IPv6 address
+	This IPv6 address will be used as a secret to generate IPv6
+	addresses for link-local addresses and autoconfigured
+	ones. All addresses generated after setting this secret will
+	be stable privacy ones by default. This can be changed via the
+	addrgenmode ip-link. conf/default/stable_secret is used as the
+	secret for the namespace, the interface specific ones can
+	overwrite that. Writes to conf/all/stable_secret are refused.
+
+	It is recommended to generate this secret during installation
+	of a system and keep it stable after that.
+
+	By default the stable secret is unset.
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
--=20
2.1.0
