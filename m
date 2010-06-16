From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix setup of RX time stamping
Date: Wed, 16 Jun 2010 14:40:15 -0700 (PDT)
Message-ID: <20100616.144015.260092207.davem@davemloft.net>
References: <95DC1AA8EC908B48939B72CF375AA5E3F03D8C46@alice.at.omicron.at>
	<20100611122023.GA1598@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Manfred.Rudigier@omicron.at, richard.cochran@omicron.at,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: cbouatmailru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754749Ab0FPVkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 17:40:04 -0400
In-Reply-To: <20100611122023.GA1598@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <cbouatmailru@gmail.com>
Date: Fri, 11 Jun 2010 16:20:23 +0400

> On Fri, Jun 11, 2010 at 01:49:05PM +0200, Manfred Rudigier wrote:
>> Previously the RCTRL_TS_ENABLE bit was set unconditionally. However, if
>> the RCTRL_TS_ENABLE is set without TMR_CTRL[TE], the driver does not work
>> properly on some boards (Anton had problems with the MPC8313ERDB and
>> MPC8568EMDS).
>> 
>> With this patch the bit will only be set if requested from user space
>> with the SIOCSHWTSTAMP ioctl command, meaning that time stamping is
>> disabled during normal operation. Users who are not interested in time
>> stamps will not experience problems with buggy CPU revisions or
>> performance drops any more.
>> 
>> The setting of TMR_CTRL[TE] is still up to the user. This is considered
>> safe because users wanting HW timestamps must initialize the eTSEC clock
>> first anyway, e.g. with the recently submitted PTP clock driver.
>> 
>> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
>> ---
> 
> Looks OK. I tested that it doesn't break anything, but I didn't
> test the timestamping functionality. So
> 
> Reviewed-by: Anton Vorontsov <cbouatmailru@gmail.com>

Applied, thanks guys.
