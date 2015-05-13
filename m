From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Bluetooth: Pre-initialize variables in read_local_oob_ext_data_complete()
Date: Wed, 13 May 2015 23:11:56 +0200
Message-ID: <0F69C638-5050-4603-A3FE-12FD8E9B27DD@holtmann.org>
References: <1429212265-26750-1-git-send-email-geert@linux-m68k.org> <A962A040-4EB5-4AE6-A790-A8767185172B@holtmann.org> <CAMuHMdUxnrg1BVoFpKExzGHKj2aOmYGp+wChhMbPfmWvMzQT=Q@mail.gmail.com> <8684664B-22C2-45E8-B547-48F173B3CA7A@holtmann.org> <CAMuHMdUXcAYe4KCqG9wV3O5QYzK9RGt+QZz7E_jk7v9yhtrkRQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdUXcAYe4KCqG9wV3O5QYzK9RGt+QZz7E_jk7v9yhtrkRQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

>>>>> net/bluetooth/mgmt.c: In function =E2=80=98read_local_oob_ext_dat=
a_complete=E2=80=99:
>>>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r256=E2=80=99 may be=
 used uninitialized in this function
>>>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h256=E2=80=99 may be=
 used uninitialized in this function
>>>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r192=E2=80=99 may be=
 used uninitialized in this function
>>>>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h192=E2=80=99 may be=
 used uninitialized in this function
>>>>>=20
>>>>> While these are false positives, the code can be shortened by
>>>>> pre-initializing the hash table pointers and eir_len. This has th=
e side
>>>>> effect of killing the compiler warnings.
>>>>=20
>>>> can you be a bit specific on which compiler version is this. I fix=
ed one occurrence that seemed valid. However in this case the compiler =
seems to be just plain stupid. On a gcc 4.9, I am not seeing these for =
example.
>>>=20
>>> gcc 4.1.2. As there were too many false positives, these warnings w=
ere
>>> disabled in later versions (throwing away the children with the bad=
 water).
>>>=20
>>> If you don't like my patch, just drop it. I only look at newly
>>> introduced warnings
>>> of this kind anyway.
>>=20
>> I really do not know what is the best solution here. This is a false=
 positive. And I have been looking at this particular code for a warnin=
g that was valid, but we missed initially. But these warnings that you =
are fixing are clearly false positive.
>=20
> I only sent patches to fix false positives if I think the patches imp=
rove the
> code. As this is a subjective matter, it's up to you as the maintaine=
r to
> decide.
>=20
>> If this only happens with an old compiler version, I would tend to l=
eave the code as is. Then again, what is the general preferred approach=
 here?
>=20
> As this is a false positive, it's clearly up to the maintainer to
> decide if the patch
> improves the code or not.

and in this case, I have no idea if I want to bother or not. I really j=
ust don=E2=80=99t. Since nobody else complained, I might just leave it =
as is since it really is a false positive.

Regards

Marcel
