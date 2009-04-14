From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 21:11:18 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242177D75A052@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1239681085.3278.122.camel@mulgrave.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>
To: "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4367 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711AbZDNEL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 00:11:27 -0400
In-Reply-To: <1239681085.3278.122.camel@mulgrave.int.hansenpartnership.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Bottomley wrote:

> On Mon, 2009-04-13 at 18:25 -0700, Matt Carlson wrote:
> > On Mon, Apr 13, 2009 at 03:32:14PM -0700, James Bottomley wrote:
> > >
> > > ion:~# ethtool -e eth0 length 0x90
> > > Address         Data
> > > ----------      ----
> > > 0x00000000      0xaa
> > > 0x00000001      0x55
> > > 0x00000002      0x99
> > > 0x00000003      0x66
> >
> > Michael noticed that your NVRAM signature is byteswapped in
> NVRAM. (!)
> > That also explains why the driver is trying to obtain the
> MAC address
> > through NVRAM, rather than getting it from shared memory.
> The device's
> > bootcode is not working correctly.
>
> Um, well, this is a parisc:  the device's boot code won't be
> working at
> all (parisc doesn't have open firmware boot).  The values
> might be laid
> down by the platform IODC, but usually for add in cards, they're the
> default initialise values the card comes up with.
>

Matt was referring to MIPS code that runs inside the MIPS core inside
the TG3 chip.  The code is loaded from NVRAM and will start running
after chip reset.  But I don't agree with Matt that the swapped NVRAM
values were caused by bad MIPS code programmed in the NVRAM.

I agree with DaveM that this appears to be a driver big-endian problem
when reading the NVRAM.  Can you run the same ethtool -e on 2.6.29 to
confirm?  Thanks.

