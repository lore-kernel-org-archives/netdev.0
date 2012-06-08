From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: tg3: transmit timed out, resetting
Date: Fri, 8 Jun 2012 09:24:11 +0800
Message-ID: <CABawtvPpaNCb00KQ1yuX2ytAhEeZ8DrYsK6VqfGo=ZOz66bMOA@mail.gmail.com>
References: <alpine.DEB.2.01.1206041546070.5568@trent.utfs.org>
	<20120606010255.GA9991@mcarlson.broadcom.com>
	<CABawtvPE_xuamH2ysL8x0WsJMXdFV5oXPrWjMT-EC-DF_kCxxw@mail.gmail.com>
	<20120606021436.GA10714@mcarlson.broadcom.com>
	<CABawtvNVKkxAgrQqJS7FJGoswQ9ZVyJcHcNwbSJQk4yscTn8gw@mail.gmail.com>
	<1338955977.2760.3603.camel@edumazet-glaptop>
	<CABawtvOBJQ-oajFQmviOdgKCub-4n06kRW+x7nE2uyiWnoky9Q@mail.gmail.com>
	<20120607225654.GA14247@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Kujau <lists@nerdbynature.de>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120607225654.GA14247@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt,
   I notice there are some AER errors ( UnsupReq+,RxErr+) with the tg3
from Christian'  lspci output,  do you know why and how to clear them ?

UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq+ ACSViol-
CESta:  RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+

Thanks,
Ethan

On Fri, Jun 8, 2012 at 6:56 AM, Matt Carlson <mcarlson@broadcom.com> wr=
ote:
> On Wed, Jun 06, 2012 at 12:52:32PM +0800, ethan zhao wrote:
>> Eric,
>> =A0 That is ask for confirmation from Matt Carlson of Broadcom.
>>
>> Ethan
>>
>> On Wed, Jun 6, 2012 at 12:12 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > On Wed, 2012-06-06 at 10:29 +0800, ethan zhao wrote:
>> >> So no way to fix it via firmware update or Linux driver ? :<
>> >
>> > Yes, but you need to cooperate, or else it might take more time th=
an
>> > necessary.
>> >
>> > Asking questions like that on lkml is not going to help very much.
>> >
>> > So, once again, we kindly ask you try a recent kernel and post
>> > register dump and some additional information when transmit timeou=
ts
>> > happen.
>> >
>> > The 'latest kernel' is either linux-3.5.rc1, or one of David Mille=
r
>> > tree :
>> >
>> > http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3D=
summary
>> >
>> > or
>> >
>> > http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net.git;a=3Dsumm=
ary
>> >
>> > Thanks
>
> Does the following patch fix your problem?
>
>
> [PATCH] tg3: Apply short DMA frag workaround to 5906
>
> 5906 devices also need the short DMA fragment workaround. =A0This pat=
ch
> makes the necessary change.
>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> ---
> =A0drivers/net/ethernet/broadcom/tg3.c | =A0 =A03 ++-
> =A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethern=
et/broadcom/tg3.c
> index d55df32..2db4d70 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14275,7 +14275,8 @@ static int __devinit tg3_get_invariants(struc=
t tg3 *tp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (tg3_flag(tp, 5755_PLUS))
> + =A0 =A0 =A0 if (tg3_flag(tp, 5755_PLUS) ||
> + =A0 =A0 =A0 =A0 =A0 GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_R=
EV_5906)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tg3_flag_set(tp, SHORT_DMA_BUG);
>
> =A0 =A0 =A0 =A0if (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_=
5719)
> --
> 1.7.3.4
>
>
