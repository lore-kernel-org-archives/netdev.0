From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] netfilter: nf_conntrack_sctp: fix build warning
Date: Mon, 24 Nov 2008 09:08:57 +0800
Message-ID: <4929FEA9.9090801@cn.fujitsu.com>
References: <20081123113315.GA16697@localhost> <20081123.135955.202482968.davem@davemloft.net> <20081124000652.GA5424@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50136 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbYKXBJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 20:09:21 -0500
In-Reply-To: <20081124000652.GA5424@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wu Fengguang said the following on 2008-11-24 8:06:
> On Sun, Nov 23, 2008 at 11:59:55PM +0200, David Miller wrote:
>> From: Wu Fengguang <fengguang.wu@intel.com>
>> Date: Sun, 23 Nov 2008 19:33:15 +0800
>>
>> linux-net is not the mailing list for network development
>> discussion, it is for user questions.  Post patches and
>> developer questions to netdev@vger.kernel.org instead.
>=20
> OK, thanks for the CC!
>=20
> Fengguang
> ---
>=20
> net/netfilter/nf_conntrack_proto_sctp.c: In function =E2=80=98sctp_pa=
cket=E2=80=99:
> net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscript=
 is above array bounds
>=20
> Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
> ---
>=20
> DISCLAIMER: I'm newbie to the code, and this fix could be wrong!
>=20
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/=
nf_conntrack_proto_sctp.c
> index ae8c260..d31ced4 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -373,6 +373,9 @@ static int sctp_packet(struct nf_conn *ct,
>  	}
>  	write_unlock_bh(&sctp_lock);
> =20
> +	if (new_state =3D=3D SCTP_CONNTRACK_MAX)
> +		goto out;
> +

print some debug info would be better?

