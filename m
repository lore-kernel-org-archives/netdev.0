From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 net-next] libceph: remove unused variable in
 handle_reply()
Date: Sat, 25 Oct 2014 11:12:16 +0200 (CEST)
Message-ID: <1805780944.182558.1414228336940.open-xchange@webmail.nmp.skynet.be>
References: <1414080959-6053-1-git-send-email-fabf@skynet.be> <CALFYKtD222g32njwF8nHz0Fbjj4p2512ka9bkADmB6S2QibgYA@mail.gmail.com>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ilya Dryomov <ilya.dryomov@inktank.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsec102.isp.belgacom.be ([195.238.20.98]:23487 "EHLO
	mailsec102.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750978AbaJYSl0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2014 14:41:26 -0400
In-Reply-To: <CALFYKtD222g32njwF8nHz0Fbjj4p2512ka9bkADmB6S2QibgYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 23 October 2014 at 18:25 Ilya Dryomov <ilya.dryomov@inktank.com> w=
rote:
>
>
> On Thu, Oct 23, 2014 at 8:15 PM, Fabian Frederick <fabf@skynet.be> wr=
ote:
> > osdmap_epoch is redundant with reassert_epoch and unused.
> >
> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> > ---
> >=C2=A0 net/ceph/osd_client.c | 2 --
> >=C2=A0 1 file changed, 2 deletions(-)
> >
> > diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
> > index f3fc54e..432bd75 100644
> > --- a/net/ceph/osd_client.c
> > +++ b/net/ceph/osd_client.c
> > @@ -1700,7 +1700,6 @@ static void handle_reply(struct ceph_osd_clie=
nt *osdc,
> > struct ceph_msg *msg,
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 reassert_epoch;
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u64 reassert_version;
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0u32 osdmap_epoch;
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int already_completed;
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 bytes;
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int i;
> > @@ -1725,7 +1724,6 @@ static void handle_reply(struct ceph_osd_clie=
nt *osdc,
> > struct ceph_msg *msg,
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0result =3D ceph_decode_32(&p);
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reassert_epoch =3D ceph_decode_32(=
&p);
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reassert_version =3D ceph_decode_6=
4(&p);
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0osdmap_epoch =3D ceph_decode_32(&p);
> >
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* lookup */
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0down_read(&osdc->map_sem);
>
> Hi Fabian,
>
> osdmap_epoch is useful for debugging, but this is wrong anyway -
> ceph_decode_32() has side effects.=C2=A0 Removing it and not adjustin=
g *p
> would make the whole thing blow up pretty fast..
>
> Thanks,
>
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Ilya

Hi Ilya,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 osdmap_epoch generates a warning with -Wunu=
sed-but-set-variable.
Maybe we could just do ceph_decode_32(&p) and remove it
(it doesn't seem to add a warning) and/or add some comment ?

Regards,
=46abian
