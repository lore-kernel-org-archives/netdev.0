From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Tue, 8 Jul 2014 08:04:41 +0200
Message-ID: <20140708060441.GB3977@localhost.localdomain>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com>
 <20140705201851.GE3869@localhost.localdomain>
 <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
 <20140707184700.GA1610@localhost.localdomain>
 <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
 <53BAF8AC.6010907@cavium.com>
 <20140707201156.GA10265@localhost.localdomain>
 <53BB0B2A.3060708@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: Chad Reese <kreese@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:64488 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbaGHGFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 02:05:08 -0400
Received: by mail-wg0-f52.google.com with SMTP id b13so5295072wgh.11
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 23:05:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53BB0B2A.3060708@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2014 at 02:03:38PM -0700, Chad Reese wrote:
> On 07/07/2014 01:11 PM, Richard Cochran wrote:
> >Don't reimplement clock servos in your driver. Instead, leave that to
> >the PTP stack (like using linuxptp's phc2sys).
> 
> I obviously did it wrong. The one line comment in
> Documentation/networking/timestamping.txt was not enough for me to
> figure out the proper usage of syststamp.

Sorry about not having clearly deprecated syststamp. We'll do that now.
Next time, putting the PTP maintainer on CC will help catch such things.
 
> I was trying to stick with standard linux userspace APIs.

There is a standard PTP hardware clock subsystem and API, as explained
in Documentation/ptp/ptp.txt.  

> People
> have no interest in the PTP clock at all. All they want is for the
> standard system time to be correct.

You can't have the time correct unless you synchronize it to
something. That is what NTP and PTP are all about. When using a PTP
hardware clock, it is necessary to synchronize the Linux system time
to it. The right way to accomplish this is using a userland PTP
stack, and the wrong way is to implement a servo in every last MAC
driver.

What I don't understand is, how does your device get the PTP time
without running the PTP protocol?

How can your device work without implementing a PTP clock? What am I
missing?

Thanks,
Richard
