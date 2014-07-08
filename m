From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Tue, 8 Jul 2014 11:41:18 +0200
Message-ID: <20140708094118.GB6249@localhost.localdomain>
References: <1404416380-3545-2-git-send-email-willemb@google.com>
 <20140705201851.GE3869@localhost.localdomain>
 <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
 <20140707184700.GA1610@localhost.localdomain>
 <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
 <53BAF8AC.6010907@cavium.com>
 <20140707201156.GA10265@localhost.localdomain>
 <53BB0B2A.3060708@cavium.com>
 <20140708060441.GB3977@localhost.localdomain>
 <53BBA0F6.3090003@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Daney <david.daney@cavium.com>
To: Chad Reese <kreese@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:35606 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbaGHJlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 05:41:42 -0400
Received: by mail-wg0-f50.google.com with SMTP id x13so4593945wgg.33
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 02:41:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53BBA0F6.3090003@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2014 at 12:42:46AM -0700, Chad Reese wrote:
> 
> You keep saying I implemented a clock servo in the MAC driver. I
> didn't, as is apparent in the code. The only kludge was a conversion
> from the PTP clock to system time with a simple offset function. I
> will fully admit it wasn't great, but it was good enough.

I assume that the point of providing both raw and sys time stamps was
to discipline the Linux system clock to the raw clock. (Otherwise, what
good are the sys values?)

In that case, the sample rate is a result of the packet activity in
the driver, and the rate is a part of the servo, at least to my
understanding.
 
> I wrote a PTPv2 daemon for Cavium that ran in userspace. It
> implemented all the v2 spec with support for both IP and 802.3
> transport. This was done from scratch as there wasn't an opensource
> PTPv2 daemon at the time. All this work actually started before
> there was any PTP timestamp support in the kernel. I originally
> started writing PTP to run on bare metal.

Okay, that is now clear. There is nothing wrong with that, although it
is too bad you cannot use the newer interface.

So, the question becomes, will removing the sys time stamp from the
octeon driver spoil your application?

[ The octeon time stamping was merged in August 2012, well after the
  PTP support which appeared in April 2011. So I guess that your
  custom application doesn't need the dual time stamps. ]

Thanks,
Richard
