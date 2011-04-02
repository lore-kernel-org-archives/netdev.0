From: Mahesh Bandewar <maheshb@google.com>
Subject: extending feature word.
Date: Fri, 1 Apr 2011 19:07:05 -0700
Message-ID: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:14262 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225Ab1DBCHJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:07:09 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p32278Vr024479
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2011 19:07:08 -0700
Received: from bwz14 (bwz14.prod.google.com [10.188.26.14])
	by wpaz33.hot.corp.google.com with ESMTP id p32276PO014374
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2011 19:07:07 -0700
Received: by bwz14 with SMTP id 14so3186427bwz.30
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2011 19:07:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your comments on my loop-back patch. I was looking at the
code today from the perspective of extending various "features" for
word to an array of words and as Michael has pointed out, it's a huge
change. So I'm thinking on the following lines
(include/linux/netdevice.h)

+#define DEV_FEATURE_WORDS =A0 =A0 =A02
+#define LEGACY_FEATURE_WORD =A0 =A00
=A0 =A0 =A0 =A0/* currently active device features */
- =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features[DEV_=
=46EATURE_WORDS];
=A0 =A0 =A0 =A0/* user-changeable features */
- =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features[D=
EV_FEATURE_WORDS];
=A0 =A0 =A0 =A0/* user-requested features */
- =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_featur=
es;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_featur=
es[DEV_FEATURE_WORDS];
=A0 =A0 =A0 =A0/* VLAN feature mask */
- =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_features=
;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_features=
[DEV_FEATURE_WORDS];
+#define legacy_features =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features[LEGACY=
_FEATURE_WORD]
+#define legacy_hw_features =A0 =A0 hw_features[LEGACY_FEATURE_WORD]
+#define legacy_wanted_features wanted_features[LEGACY_FEATURE_WORD]
+#define=A0legacy_vlan_features =A0 =A0vlan_features[LEGACY_FEATURE_WOR=
D]


So that it will be a matter of -

s/features/legacy_features/
s/hw_features/legacy_hw_features/
s/wanted_features/legacy_wanted_features/
s/vlan_features/legacy_vlan_features/

to start with as a first step. Once this is done, legacy_* can be
changed with respective arrays and modified as per the need. Comments?

--mahesh..
