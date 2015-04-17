From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Pre-initialize variables in read_local_oob_ext_data_complete()
Date: Fri, 17 Apr 2015 13:38:47 -0700
Message-ID: <8684664B-22C2-45E8-B547-48F173B3CA7A@holtmann.org>
References: <1429212265-26750-1-git-send-email-geert@linux-m68k.org> <A962A040-4EB5-4AE6-A790-A8767185172B@holtmann.org> <CAMuHMdUxnrg1BVoFpKExzGHKj2aOmYGp+wChhMbPfmWvMzQT=Q@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMuHMdUxnrg1BVoFpKExzGHKj2aOmYGp+wChhMbPfmWvMzQT=Q@mail.gmail.com>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Geert,

>>> net/bluetooth/mgmt.c: In function =E2=80=98read_local_oob_ext_data_=
complete=E2=80=99:
>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r256=E2=80=99 may be u=
sed uninitialized in this function
>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h256=E2=80=99 may be u=
sed uninitialized in this function
>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r192=E2=80=99 may be u=
sed uninitialized in this function
>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h192=E2=80=99 may be u=
sed uninitialized in this function
>>>=20
>>> While these are false positives, the code can be shortened by
>>> pre-initializing the hash table pointers and eir_len. This has the =
side
>>> effect of killing the compiler warnings.
>>=20
>> can you be a bit specific on which compiler version is this. I fixed=
 one occurrence that seemed valid. However in this case the compiler se=
ems to be just plain stupid. On a gcc 4.9, I am not seeing these for ex=
ample.
>=20
> gcc 4.1.2. As there were too many false positives, these warnings wer=
e
> disabled in later versions (throwing away the children with the bad w=
ater).
>=20
> If you don't like my patch, just drop it. I only look at newly
> introduced warnings
> of this kind anyway.

I really do not know what is the best solution here. This is a false po=
sitive. And I have been looking at this particular code for a warning t=
hat was valid, but we missed initially. But these warnings that you are=
 fixing are clearly false positive.

If this only happens with an old compiler version, I would tend to leav=
e the code as is. Then again, what is the general preferred approach he=
re?

Regards

Marcel
