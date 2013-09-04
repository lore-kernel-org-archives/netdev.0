From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH] r8169: add ethtool eeprom change/dump feature
Date: Wed, 04 Sep 2013 11:55:59 +0200
Message-ID: <9994507.zDXvCracdk@al>
References: <1377787491-2932-1-git-send-email-lekensteyn@gmail.com> <20130903.215935.1007110179484647485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	hayeswang@realtek.com, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:34365 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934205Ab3IDJ4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 05:56:04 -0400
Received: by mail-bk0-f41.google.com with SMTP id na10so47886bkb.14
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 02:56:02 -0700 (PDT)
In-Reply-To: <20130903.215935.1007110179484647485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 September 2013 21:59:35 David Miller wrote:
> From: Peter Wu <lekensteyn@gmail.com>
> Date: Thu, 29 Aug 2013 16:44:51 +0200
> 
> > This adds the ability to read and change EEPROM for 93C46/93C56 serial
> > EEPROM. Two-Wire serial interface and SPI are not supported. (Do not
> > even try this for SPI or other chips, it may break your hardware.)
> 
> Please block the operation on configurations, such as the aforementioned
> SPI, where it won't work.

I do not know how to detect those, as far as I know it's harmless, the r8168 
vendor driver does not perform other checks either. If I look at "Realtek 
RTL8411 EEPROM/eFUSE Datasheet 1.1", then SPI access is done via CONFIG0 which 
is then at offset 51h and not 50h (which is used for 9346CR).

This SPI seems to be used for the Boot ROM, not EEPROM. Even the "RTL8111E-VL-
CG" (May 2012) mentions the 9346CR register, so I think it is safe to assume 
that nothing breaks. At worst you read invalid values (ff) and writes are no-
op.

I can remove this scary warning from the commit message, but it would really 
be nice if a Realtek engineer could give more information on this.

Regards,
Peter
