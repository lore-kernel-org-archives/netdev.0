From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 linux-next] zd1201: replace kmalloc/memset by
 kzalloc
Date: Thu, 16 Oct 2014 10:08:50 +0200 (CEST)
Message-ID: <346236957.6316.1413446930736.open-xchange@webmail.nmp.skynet.be>
References: <1413304831-7203-1-git-send-email-fabf@skynet.be> <1413306955.3269.30.camel@joe-AO725> <87iojm8qxp.fsf@nemi.mork.no>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Joe Perches <joe@perches.com>,
	=?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87iojm8qxp.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 14 October 2014 at 20:08 Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>
>
> Joe Perches <joe@perches.com> writes:
>
> > And does this really need to be alloc'd?
>
> Yes, it does. It is used as a transfer_buffer in usb_fill_bulk_urb() =
and
> must be "suitable for DMA".=C2=A0 From include/linux/usb.h:
>
> /**
>=C2=A0 * struct urb - USB Request Block
> ..
>=C2=A0 * @transfer_buffer:=C2=A0 This identifies the buffer to (or fro=
m) which the I/O
>=C2=A0 *=C2=A0 =C2=A0 =C2=A0 request will be performed unless URB_NO_T=
RANSFER_DMA_MAP is set
>=C2=A0 *=C2=A0 =C2=A0 =C2=A0 (however, do not leave garbage in transfe=
r_buffer even then).
>=C2=A0 *=C2=A0 =C2=A0 =C2=A0 This buffer must be suitable for DMA; all=
ocate it with
>=C2=A0 *=C2=A0 =C2=A0 =C2=A0 kmalloc() or equivalent.=C2=A0 For transf=
ers to "in" endpoints, contents
>=C2=A0 *=C2=A0 =C2=A0 =C2=A0 of this buffer will be modified.=C2=A0 Th=
is buffer is used for the data
>=C2=A0 *=C2=A0 =C2=A0 =C2=A0 stage of control transfers.
>
>

Adding a structure would be a nice design update indeed but this would =
require
some testing...Separate patch maybe ?
=C2=A0
=46abian

>
> Bj=C3=B8rn
