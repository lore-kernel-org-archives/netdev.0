From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V2 0/7] support the cpts found on am335x devices
Date: Tue, 16 Oct 2012 19:14:08 +0200
Message-ID: <20121016171407.GA2176@netboy.at.omicron.at>
References: <cover.1350329726.git.richardcochran@gmail.com>
 <EB1619762EAF8B4E97A227FB77B7E0293E9F82F0@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44796 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab2JPROW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 13:14:22 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so3870391wey.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 10:14:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9F82F0@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 04:33:55PM +0000, N, Mugunthan V wrote:
> I had seen some issues with the patch series.

Please take another look. Excepting the last, none of your points
holds water.
 
> * CPTS will hold only LSB 32 bits of 64 bit Timer and the upper 32 bit
>   time value has to be taken care by the software, but the time stamp
>   which is passed to skb or PTP clock consist of only 32 bit time value

The driver handles this already.

> * CPTS interrupts should be utilized to service Half and Full roll over
>   events as it is non sync events with respect to get/set time and PTP
>   pkt Tx/Rx

Nope, no need for interrupts, since we already have a better way to
handle this.

> * CPTS Time which is obtained from hardware is not actually a nano
>   seconds as the CPTS ref clock is tied to 250MHz for AM335x.

Did you even look at the code in my patch?

> * CPSW register mapping done in this patch series removes the CPSW
>   driver support for previous version found in TI814x

In which Linux version (or commit) did this driver appear?
I never saw it.

> * CPSW Time stamping is done only for port 0 and port 1 is not done

Yes, you are right, and it is strange that the hardware time stamps on
the external ports of the switch, and not at the host port as it
should. Of course it does present us with a problem, since we cannot
reasonably have both ports time stamping at the same time. I propose
simply using a device tree attribute to tell which port to activate.

Thanks,
Richard
