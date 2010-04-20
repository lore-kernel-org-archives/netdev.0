From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Mon, 19 Apr 2010 23:43:49 -0500
Message-ID: <DD217C72-156B-403D-B83B-EB365C782F2B@kernel.crashing.org>
References: <1271632401-2472-1-git-send-email-afleming@freescale.com> <m2ged82fe3e1004191408p53f19073x106ef56677c8a5df@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andy Fleming <afleming@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Timur Tabi <timur.tabi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:32771 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab0DTEn5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 00:43:57 -0400
In-Reply-To: <m2ged82fe3e1004191408p53f19073x106ef56677c8a5df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 19, 2010, at 4:08 PM, Timur Tabi wrote:

> On Sun, Apr 18, 2010 at 6:13 PM, Andy Fleming <afleming@freescale.com> wrote:
> 
>> -               while (!(gfar_read(&regs->ievent) &
>> -                        (IEVENT_GRSC | IEVENT_GTSC)))
>> +               while ((gfar_read(&regs->ievent) &
>> +                        (IEVENT_GRSC | IEVENT_GTSC)) !=
>> +                        (IEVENT_GRSC | IEVENT_GTSC))
>>                        cpu_relax();
> 
> How about using spin_event_timeout()?  It streamlines this process and
> includes a timeout.
> 
> The U-Boot version of this code doesn't have a timeout either, but
> spin_event_timeout() is not available in U-Boot.

spin_event_timeout doesn't make sense for this.  The patch is fine.

- k