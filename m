From: Mathias Krause <minipli@googlemail.com>
Subject: Re: bug in networking code causes GPF
Date: Thu, 27 Nov 2014 20:26:57 +0100
Message-ID: <CA+rthh-4Xa-vRsjvA7y9a64MFJbm8Kyt5o7shRZKZBF6HdMtxA@mail.gmail.com>
References: <1417102910.5477463ec9948@mail.inbox.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: =?UTF-8?B?0JTQtdC90LjRgdC60LAt0YDQtdC00LjRgdC60LA=?=
	<slim@inbox.lv>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417102910.5477463ec9948@mail.inbox.lv>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27 November 2014 at 16:41, =D0=94=D0=B5=D0=BD=D0=B8=D1=81=D0=BA=D0=B0=
-=D1=80=D0=B5=D0=B4=D0=B8=D1=81=D0=BA=D0=B0 <slim@inbox.lv> wrote:
> well, I will try to disable CONFIG_PAX_MEMORY_SANITIZE.
> Will take some time to make sure that this resolve the issue

That should fix the issue for you. You could also try to add
"pax_sanitize_slab=3D0" to the kernel command line to disable slab
sanitization.

> =D0=A6=D0=B8=D1=82=D0=B8=D1=80=D0=BE=D0=B2=D0=B0=D0=BD=D0=B8=D0=B5 Da=
niel Borkmann <dborkman@redhat.com> :
>> On 11/27/2014 02:35 PM, =D0=94=D0=B5=D0=BD=D0=B8=D1=81=D0=BA=D0=B0-=D1=
=80=D0=B5=D0=B4=D0=B8=D1=81=D0=BA=D0=B0 wrote:
>> > [...]
>> > [354497.932330] ... RBX: fefefefefefefefe ...
>> > [...]
>> > [354497.934903] Code: c2 85 d2 49 8b 86 d0 04 00 00 74 14 66 45 85=
 ff 75 0e 65 ff 40 04 e8 85 f6 a4 ff 48 89 d8 eb 69 65 ff 00 48 8b 1b f=
6 c3 01 75 0f <8b> 43 10 39 45 00 b8 00 00 00 00 74 83 eb 9d 48 d1 eb 4=
c 39 eb

That's: mov    0x10(%rbx),%eax

RBX contains the PaX sanitize pattern, that's the reason for the #GP.
So this is very likely the bug Daniel mentioned.

Please update to a recent grsec kernel to get this issue fixed. It's
fixed in the stable patches as well as in the test patch.


Regards,
Mathias
