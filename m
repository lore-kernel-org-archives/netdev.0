From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] netfilter: nf_conntrack_sctp: fix build warning
Date: Mon, 24 Nov 2008 08:06:52 +0800
Message-ID: <20081124000652.GA5424@localhost>
References: <20081123113315.GA16697@localhost> <20081123.135955.202482968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "kaber@trash.net" <kaber@trash.net>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52020 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887AbYKXAHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 19:07:05 -0500
Content-Disposition: inline
In-Reply-To: <20081123.135955.202482968.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2008 at 11:59:55PM +0200, David Miller wrote:
> From: Wu Fengguang <fengguang.wu@intel.com>
> Date: Sun, 23 Nov 2008 19:33:15 +0800
>=20
> linux-net is not the mailing list for network development
> discussion, it is for user questions.  Post patches and
> developer questions to netdev@vger.kernel.org instead.

OK, thanks for the CC!

=46engguang
---

net/netfilter/nf_conntrack_proto_sctp.c: In function =E2=80=98sctp_pack=
et=E2=80=99:
net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscript i=
s above array bounds

Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
---

DISCLAIMER: I'm newbie to the code, and this fix could be wrong!

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf=
_conntrack_proto_sctp.c
index ae8c260..d31ced4 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -373,6 +373,9 @@ static int sctp_packet(struct nf_conn *ct,
 	}
 	write_unlock_bh(&sctp_lock);
=20
+	if (new_state =3D=3D SCTP_CONNTRACK_MAX)
+		goto out;
+
 	nf_ct_refresh_acct(ct, ctinfo, skb, sctp_timeouts[new_state]);
=20
 	if (old_state =3D=3D SCTP_CONNTRACK_COOKIE_ECHOED &&
