From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Silicom bypass driver promote from staging
Date: Thu, 7 Aug 2014 09:55:45 -0700
Message-ID: <20140807095545.2dd60024@haswell.linuxnetplumber.net>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
	<20140805150957.GC27303@kroah.com>
	<3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:48529 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567AbaHGQzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 12:55:48 -0400
Received: by mail-pa0-f65.google.com with SMTP id kx10so2728416pab.0
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 09:55:48 -0700 (PDT)
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Aug 2014 09:26:54 +0000
David Hendel <david@silicom.co.il> wrote:

> Let me know how we can proceed with that. what should be the next step.
> -------------
> Theory of Operation:
> The Silicom Bypass Network Interface Cards (NICs) are network cards with paired ports (2 or 4).
> The pairs either act as a "wire" allowing the network packets to pass or insert the device in between the two ports.  When paired with the on-board hardware watchdog or other failsafe, they provide high availability for the network in the face of software outages or maintenance.
> 
> The software requirements are for a kernel level driver that interfaces with the bypass and watchdog, as well as for control software. User control can be either the provided standalone executable
> (/bin/bpctl) or the API exposed by the Silicom library. 

The current driver uses a device specific /proc interface.
That API programming model will not likely be acceptable in a standard network driver.
Please consider doing something generic with netlink.
