From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] bridge: multicast: disable port when in
 blocking state
Date: Tue, 23 Jun 2015 07:52:15 +0800
Message-ID: <20150622235215.GA14897@gondor.apana.org.au>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
 <1435003931-6418-1-git-send-email-nikolay@cumulusnetworks.com>
 <EA66CF77-F024-471C-A8F1-A7E6C3DB1721@cumulusnetworks.com>
 <709324EA-9BEC-43AD-9DC1-55F712C378E6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com,
	davem@davemloft.net, stephen@networkplumber.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57774 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbbFVXwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 19:52:22 -0400
Content-Disposition: inline
In-Reply-To: <709324EA-9BEC-43AD-9DC1-55F712C378E6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2015 at 11:38:36PM +0300, Nikolay Aleksandrov wrote:
>=20
> One more thing - I don=E2=80=99t think we need any additional changes=
 because there=E2=80=99s a check in
> br_multicast_port_query_expired():
>       if (port->state =3D=3D BR_STATE_DISABLED ||
>             port->state =3D=3D BR_STATE_BLOCKING)
>                 goto out;
>=20
> So it looks like the port should be fine (i.e. not sending) when it g=
oes in blocking state.

Thanks for looking into this! Perhaps we could at least add a
comment to state that the disable_port isn't needed because the
timers will expire and kill themselves automatically?  I think
adding it to the place where you were going to place the disable_port
call would be the most obvious.

Thanks,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
