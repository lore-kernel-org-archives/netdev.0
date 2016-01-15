From: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@gmail.com>
Subject: nf_conntrack_h323: Fix locking in process_urq
Date: Fri, 15 Jan 2016 22:55:18 +0100
Message-ID: <1452894918.4622.3.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36898 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814AbcAOVzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 16:55:21 -0500
Received: by mail-wm0-f52.google.com with SMTP id f206so44489870wmf.0
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 13:55:21 -0800 (PST)
Received: from alpha.fritz.box (dslb-094-217-060-214.094.217.pools.vodafone-ip.de. [94.217.60.214])
        by smtp.gmail.com with ESMTPSA id lx4sm12362412wjb.5.2016.01.15.13.55.19
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 13:55:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_ct_remove_expectations has to be called under nf_conntrack_expect_lo=
ck
=C2=A0=C2=A0=C2=A0=C2=A0
Signed-off-by: Sebastian P=C3=B6hn <sebastian.poehn@gmail.com>

---

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_=
conntrack_h323_main.c
index 9511af0..d477375 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1518,7 +1518,9 @@ static int process_urq(struct sk_buff *skb, struc=
t nf_conn *ct,
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Clear old expect */
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0spin_lock_bh(&nf_conntrack_e=
xpect_lock);
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0nf_ct_remove_expectatio=
ns(ct);
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0spin_unlock_bh(&nf_conntrack=
_expect_lock);
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0info->sig_port[dir] =3D=
 0;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0info->sig_port[!dir] =3D=
 0;
=C2=A0
