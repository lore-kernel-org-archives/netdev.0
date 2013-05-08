From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [Suggestion] Bluetooth: hidp: redundant initialization or issue
 for function hidp_copy_session
Date: Wed, 08 May 2013 09:50:25 +0800
Message-ID: <5189AF61.7020800@asianux.com>
References: <518906A8.7060708@asianux.com> <51890AC9.7010501@asianux.com> <CANq1E4Q8g6Uy5DMiEf3aEBmfWN=KnVCfqxErYr=ZWD94D4vmAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
In-Reply-To: <CANq1E4Q8g6Uy5DMiEf3aEBmfWN=KnVCfqxErYr=ZWD94D4vmAQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013=E5=B9=B405=E6=9C=8808=E6=97=A5 03:37, David Herrmann wrote:
> Hi
>=20
> On Tue, May 7, 2013 at 4:08 PM, Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org> wro=
te:
>> Hello Maintainers:
>>
>> In net/bluetooth/hidp/core.c, for hidp_copy_session(), the
>> 'session->input' and 'session->hid' are conflict with each other.
>>
>> And excuse me, I do not quit know the details, but I think we have 2
>> choices for fixing it:
>>
>>   one is ''if (session->input) { } else if (session->hid) { };''
>>   the other is ''if (seesion->hid) { } else if (session->input) { };=
''
>>
>> The first choice assumes the original code has a logical issue; the
>> second choice assumes the original code has redundant initialization=
=2E
>=20
> The code is fine. Only one of "->input" or "->hid" can be valid at a
> time. And exactly one of them is guaranteed to be valid. See
> hidp_session_dev_init().
>=20

Oh, really it is, thanks.

> I fixed all code that I changed during the rework to say:
>=20
> if (session->hid)
> ..
> else if (session->input)
> ..
>=20
> It makes the code more clear. But I avoided touching all the other
> places that I didn't change, as the code is technically right. Anyway=
,
> I don't care whether we want to fix all other occurrences to use "els=
e
> if". Feel free to send a patch.
>=20

Me too: "avoided touching all the other places that I didn't change, as
the code is technically right".

Thanks.

--=20
Chen Gang

Asianux Corporation
