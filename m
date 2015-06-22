From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: multicast: disable port when in blocking state
Date: Mon, 22 Jun 2015 23:25:46 +0300
Message-ID: <EA66CF77-F024-471C-A8F1-A7E6C3DB1721@cumulusnetworks.com>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com> <1435003931-6418-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sashok@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:35311 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbFVUZv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 16:25:51 -0400
Received: by wgbhy7 with SMTP id hy7so151054719wgb.2
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 13:25:49 -0700 (PDT)
In-Reply-To: <1435003931-6418-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 22, 2015, at 11:12 PM, Nikolay Aleksandrov <nikolay@cumulusnet=
works.com> wrote:
>=20
> Currently when a port goes in blocking state the multicast is not
> disabled. Fix it by disabling a port if its state has transitioned to
> blocking, this has effect for both user- and kernel-space stp.
>=20
> Reported-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> note: this is on top of patch:
> "bridge: multicast: start querier timer when running user-space stp"
>=20
> net/bridge/br_stp.c | 2 ++
> 1 file changed, 2 insertions(+)
>=20
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index e7ab74b405a1..1a73c5595f52 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -463,6 +463,8 @@ void br_port_state_selection(struct net_bridge *b=
r)
>=20
> 		if (p->state !=3D BR_STATE_BLOCKING)
> 			br_multicast_enable_port(p);
> +		else
> +			br_multicast_disable_port(p);
> 		if (p->state =3D=3D BR_STATE_FORWARDING)
> 			++liveports;
> 	}
> --=20
> 2.4.3
>=20

Actually I don=E2=80=99t think this is the correct way to go about this=
 because when the
port goes in blocking state and br_multicast_disable_port() is called t=
hen all groups are deleted
which includes the user-added ones.--
To unsubscribe from this list: send the line "unsubscribe netdev" in
