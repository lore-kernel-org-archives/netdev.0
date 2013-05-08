From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: hidp: using strlcpy or strcpy instead of strncpy
Date: Wed, 08 May 2013 09:02:15 +0800
Message-ID: <5189A417.503@asianux.com>
References: <518906A8.7060708@asianux.com> <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, andrei.emeltchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013=C4=EA05=D4=C208=C8=D5 03:31, David Herrmann wrote:
> On Tue, May 7, 2013 at 3:50 PM, Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org> wro=
te:
>> >
>> > For NUL terminated string, need always let it ended by zero.
>> >
>> > Since have already called memcpy() to initialize 'ci', so need not
>> > redundent initializations.
>> >
>> > Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
>> > ---
>> >  net/bluetooth/hidp/core.c |   10 +++-------
>> >  1 files changed, 3 insertions(+), 7 deletions(-)
>> >
>> > diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
>> > index 940f5ac..9a8ae63 100644
>> > --- a/net/bluetooth/hidp/core.c
>> > +++ b/net/bluetooth/hidp/core.c
>> > @@ -76,25 +76,21 @@ static void hidp_copy_session(struct hidp_sess=
ion *session, struct hidp_conninfo
>> >         ci->flags =3D session->flags;
>> >         ci->state =3D BT_CONNECTED;
>> >
>> > -       ci->vendor  =3D 0x0000;
>> > -       ci->product =3D 0x0000;
>> > -       ci->version =3D 0x0000;
>> > -
>> >         if (session->input) {
>> >                 ci->vendor  =3D session->input->id.vendor;
>> >                 ci->product =3D session->input->id.product;
>> >                 ci->version =3D session->input->id.version;
>> >                 if (session->input->name)
>> > -                       strncpy(ci->name, session->input->name, 12=
8);
>> > +                       strlcpy(ci->name, session->input->name, 12=
8);
>> >                 else
>> > -                       strncpy(ci->name, "HID Boot Device", 128);
>> > +                       strcpy(ci->name, "HID Boot Device");
> I'd actually prefer strlcpy() here, too (better be safe). Other than
> that the patch looks fine.

OK, thanks. I will send patch v2.

--=20
Chen Gang

Asianux Corporation
