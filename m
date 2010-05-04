From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 04 May 2010 09:57:54 +0200
Message-ID: <4BDFD382.1010309@grandegger.com>
References: <20100429091936.GA6703@riccoc20.at.omicron.at> <4BDD5910.1040604@grandegger.com> <20100503100754.GA30417@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:49755 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab0EDH6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 03:58:25 -0400
In-Reply-To: <20100503100754.GA30417@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2010 12:07 PM, Richard Cochran wrote:
> On Sun, May 02, 2010 at 12:50:56PM +0200, Wolfgang Grandegger wrote:
>>
>> As long as the device is in use by an application, no other can access
>> it, because the mutex is locked. Other application may want to read the
>> PTP clock time while ptpd is running, though.
> 
> Yes, of course. I implemented it that way just to get started. I first
> want to concentrate on getting the basic drivers in place (still have
> IXP46x and Phyter to do), and then on the ancillary features, like
> timers, time stamping external inputs, and so on.
> 
> I understand that some fine grained access control to the PTP clock
> woul be nice to have, but I am not sure exactly what would work best,
> and I would like to save that decision for later...

OK, fair enough.

> However, if you have some ideas, please take a look at the list of
> features in the docu, and explain how you would like the access
> control to work.

The fine grain locking for set/get properties is tricky. I personally
would just require "CAP_SYS_TIME" for setting properties and a
spin_lock_irq* to protect against concurrent access, just like for
setting/getting system clock properties.

> Or better yet, post a patch ;)

Would do if we could agree on the solution mentioned above.

Wolfgang.

