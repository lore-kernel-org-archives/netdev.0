From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC 1/4] netlink: make extended ACK setting NULL-friendly
Date: Tue, 25 Apr 2017 13:53:06 -0700
Message-ID: <20170425135306.0ff1db27@cakuba.netronome.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
        <20170425080644.122536-2-jakub.kicinski@netronome.com>
        <1493108014.2592.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com
To: Johannes Berg <johannes@sipsolutions.net>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:45913 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1172628AbdDYUx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 16:53:29 -0400
In-Reply-To: <1493108014.2592.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Apr 2017 10:13:34 +0200, Johannes Berg wrote:
> On Tue, 2017-04-25 at 01:06 -0700, Jakub Kicinski wrote:
>=20
> > +#define NL_SET_ERR_MSG(extack, msg) do {		\
> > +	struct netlink_ext_ack *_extack =3D (extack);	\
> > +	static const char _msg[] =3D (msg);		\
> > +							\
> > +	if (_extack)					\
> > +		_extack->_msg =3D _msg;			\
> > +	else						\
> > +		pr_info("%s\n", _msg);			\
> > =C2=A0} while (0) =20
>=20
> That's a good point, I used it only for genetlink so far where it was
> guaranteed non-NULL.
>=20
> I'm not really sure about the printing though - I'd rather not people
> start relying on that and then we convert to have non-NULL and the
> message disappears as a result ...

Yes, agreed.  I don't really know what to do about that one though :|
One could argue people may already be depending on the messages which
I'm converting in this series...  On the other hand, that would
be considering logs as part of the ABI which we don't want to do.

I'm leaning towards dropping the else clause and never printing, that
will add an incentive for people to convert more paths to provide the
ext ack.  Any thoughts on that?
