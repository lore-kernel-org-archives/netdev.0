From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Mon, 7 Jul 2014 22:11:56 +0200
Message-ID: <20140707201156.GA10265@localhost.localdomain>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com>
 <20140705201851.GE3869@localhost.localdomain>
 <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
 <20140707184700.GA1610@localhost.localdomain>
 <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
 <53BAF8AC.6010907@cavium.com>
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
Received: from mail-we0-f175.google.com ([74.125.82.175]:62818 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbaGGUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 16:12:16 -0400
Received: by mail-we0-f175.google.com with SMTP id k48so4788461wev.34
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 13:12:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53BAF8AC.6010907@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2014 at 12:44:44PM -0700, Chad Reese wrote:
> 
> A hardware timer used for ethernet timestamps is completely
> independent from the kernel's software view of time. Since the
> hardware timestamps are only exposed in the driver, how can they be
> correlated with system time? If the driver doesn't do it, then
> nobody else knows how.

Um, implement a PTP Hardware Clock device?

Don't reimplement clock servos in your driver. Instead, leave that to
the PTP stack (like using linuxptp's phc2sys).
 
> For Octeon, you can optionally use the hardware timestamp as the
> system clock reference. Most people don't, but it is the only way to
> get the system time to be accurate. 1588 can synchronize two Octeon
> boards to less than 1ns for the hardware timer. The Linux software
> timers is always farther off.

1588 cannot synchronize boards unless you expose the clock to the
userland PTP stack. Why don't you do that?

Thanks,
Richard
