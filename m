From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Sun, 02 May 2010 13:51:23 +0200
Message-ID: <4BDD673B.6070108@grandegger.com>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <4BD97573.5050101@grandegger.com> <20100429153401.GA26741@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:60724 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755231Ab0EBLxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 07:53:17 -0400
In-Reply-To: <20100429153401.GA26741@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> On Thu, Apr 29, 2010 at 02:02:59PM +0200, Wolfgang Grandegger wrote:
>> I realized two other netdev drivers already supporting PTP timestamping:
>> igb and bfin_mac. From the PTP developer point of view, the interface
>> looks rather complete to me and it works fine on my MPC8313 setup.
> 
> Do you know whether these two also have PTP clocks? If so, is the API
> that I suggested going to work for controlling those clocks, too?
> 
>> The only thing I stumbled over was that PTP clock registration
>> failed when PTP support is statically linked into the kernel.
> 
> Okay, will look into that...

With subsys_initcall(), ptp_gianfar_init() is called very early and
*before* ptp_init(). It works fine with module_init(). The
ptp_gianfar_init() is then called after gianfar_init().

There is another minor issue with module init/probe ordering.
gianfar_ptp_probe() does overtake the time from the system clock, which
may happen before the RTC is probed and initialized. But syncing with
the system time is a separate issue anyway.

Wolfgang.
