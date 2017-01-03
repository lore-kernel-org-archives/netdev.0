From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence GEM.
Date: Tue, 3 Jan 2017 10:36:11 +0530
Message-ID: <CAFcVECK1vt7Hu4tgSZ2+kKpMxoT-wpikMDq65HaxRv-EMgobHA@mail.gmail.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170102113155.GA16373@localhost.localdomain> <0717c63b-2e29-9ad1-7f01-39817980933f@atmel.com>
 <20170102161359.GD3609@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Rafal Ozieblo <rafalo@cadence.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170102161359.GD3609@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On Mon, Jan 2, 2017 at 9:43 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Jan 02, 2017 at 03:47:07PM +0100, Nicolas Ferre wrote:
>> Le 02/01/2017 =C3=A0 12:31, Richard Cochran a =C3=A9crit :
>> > This Cadence IP core is a complete disaster.
>>
>> Well, it evolved and propose several options to different SoC
>> integrators. This is not something unusual...
>> I suspect as well that some other network adapters have the same
>> weakness concerning PTP timestamp in single register as the early
>> revisions of this IP.
>
> It appears that this core can neither latch the time on read or write,
> or even latch time stamps.  I have worked with many different PTP HW
> implementations, even early ones like on the ixp4xx, and it is no
> exaggeration to say that this one is uniquely broken.
>
>> I suspect that Rafal tend to jump too quickly to the latest IP revisions
>> and add more options to this series: let's not try to pour too much
>> things into this code right now.
>
> Why can't you check the IP version in the driver?

There is an IP revision register but it would be probably be better
to rely on "caps" from the compatibility strings - to cover SoC
specific implementations. Also, when this extended BD is
added (with timestamp), additional words will need to be added
statically which will be consistent with Andrei's CONFIG_
checks.

>
> And is it really true that the registers don't latch the time stamps,
> as Rafal said?  If so, then we cannot accept the non-descriptor driver
> version, since it cannot possibly work correctly.
>

AFAIK, the two sets of registers only hold the timestamp till the next
event (or peer event) packet comes in.
I understand that it is not accurate - it is an initial version.

Regards,
Harini
