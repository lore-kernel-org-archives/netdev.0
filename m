From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 5/5] qed*: Add support for read/write of eeprom
Date: Mon, 18 Apr 2016 03:59:42 +0000
Message-ID: <CO2PR11MB0088716755CC57276455ADA4976B0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1460921195-23352-6-git-send-email-Yuval.Mintz@qlogic.com>
 <20160417.191849.2044093416855662399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0116.outbound.protection.outlook.com ([65.55.169.116]:48997
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751287AbcDREPn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 00:15:43 -0400
In-Reply-To: <20160417.191849.2044093416855662399.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > There's quite a bit of `magic' here [based on the ethtool `magic'
> > field] which is retained by the user application responsible for
> > interacting with the driver for the purpose of upgrading the nvram
> > image.
> 
> This is not how the 'magic' value of the eeprom structure is specified to be used,
> please use it the way it is supposed to be used rather than inventing semantics
> which only apply to your device.
> 
> The entire point of defining a common interface for device driver interface
> interaction with the user is exactly so that driver authors don't do things like this.

While I obviously get what you're writing, I actually think this is the
more revealing API option.

I.e., the bottom line is that write to this device's nvram is complex in
nature and requires interacting with the management firmware.
The other immediate option would have been to implement this
in driver as simple read/write toward the management firmware,
and let the management firmware analyze what it needs to do with
the data based on hidden meta-data inside the buffer written by the
application.

While this might be less 'extending' of the ethtool API, it's a security-
in-obscurity kind of API, where a reviewer can't possibly know how to
perform read/write from reading the driver code.

The third option I see is to completely ditch this, stating that although
We obviously CAN set the non-volatile memory we CAN'T do it with the
regular API, and to move into doing this via some proprietary API such
as debugfs.

Thanks,
Yuval 
