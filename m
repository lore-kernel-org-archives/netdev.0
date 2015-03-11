From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Wed, 11 Mar 2015 11:20:59 +0000
Message-ID: <5500251B.8010900@linn.co.uk>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk> <20150225151945.GB7703@localhost.localdomain> <20150225170127.GD7703@localhost.localdomain> <54EE0268.2040201@linn.co.uk> <20150225173053.GE7703@localhost.localdomain> <54F0A4C4.3020407@linn.co.uk> <20150227181447.GA11594@localhost.localdomain> <54F98660.5070805@linn.co.uk> <20150306152239.GC26349@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150306152239.GC26349@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 06/03/15 15:22, Richard Cochran wrote:
> I don't really know what the problem here is.  Yes, there is some
> networking configuration that you need to do when administering a
> network using PTP protocols.  But these protocols (1588 aka PTP, and
> 802.1AS aka gPTP) do offer means for dealing with this.  In
> particular, there is no danger mixing 1588 devices with audio devices,
> because the gPTP protocol uses a different transport flag.
>
> In any case, this has nothing at all to do with the kernel interface.

Our feeling is that we will have to test and verify that a move to gPTP
will fit with the use cases that we have to support and that will
require a fair amount of effort and rewrite of application software.
If the driver is not acceptable with the current interface we may need
to maintain it as a private patch until we are ready to move to gPTP
as you recommend.

>
> If you want to try and integrate your custom protocols into the
> networking stack, by all means please post them.  I would certainly
> support expanding the time stamping interface to include your
> protocol's packet types (like adding them to hwtstamp_rx_filters).
> Maybe that would be enough for you?

I was referring to the Songcast protocol we are using which is part
of the OpenHome suite (www.openhome.org) and runs on top of UDP.
It could be filtered by testing the first 5 bytes of the payload.
In our implementation we also add the destination IP and port to
the filter to make it more reliable, but hwtstamp_rx_filters cannot
accept parameters. However, I will test that and maybe come back with
a patch to expand the hwtstamp_rx_filter enum initially?

>
> Thanks,
> Richard
>

Thank you,
Stathis
