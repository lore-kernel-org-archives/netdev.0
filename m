From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 2/9] bnxt_en: Add Support for ETHTOOL_GMODULEINFO
 and ETHTOOL_GMODULEEEPRO
Date: Sat, 14 May 2016 23:01:18 -0700
Message-ID: <CACKFLinShcLykdPDUN0wBb1f10_i8MyLZXZt4jObKuZADU+ezA@mail.gmail.com>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
	<1463272188-30025-3-git-send-email-michael.chan@broadcom.com>
	<1463275917.2631.31.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36563 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbcEOGBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 02:01:19 -0400
Received: by mail-oi0-f49.google.com with SMTP id x201so227392890oif.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 23:01:19 -0700 (PDT)
In-Reply-To: <1463275917.2631.31.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 6:31 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sat, 2016-05-14 at 20:29 -0400, Michael Chan wrote:
>> From: Ajit Khaparde <ajit.khaparde@broadcom.com>
> [...]
>> +     /* Read A2 portion of the EEPROM */
>> +     if (length) {
>> +             start -= ETH_MODULE_SFF_8436_LEN;
>> +             bnxt_read_sfp_module_eeprom_info(bp, I2C_DEV_ADDR_A2, 1, start,
>> +                                              length, data + start);
>
> The output address calculation (data + start) makes no sense at all.
> If eeprom->offset < ETH_MODULE_SFF_8436_LEN then start == 0 here and
> this read overwrites earlier data in the output buffer.  If
> eeeprom->offset > ETH_MODULE_SFF_8436_LEN then start > 0 here and this
> overruns the output buffer.
>
> I think that 'data' should be incremented along with 'start' in the
> previous if-block.
>

Yes, you're right.  We'll fix it and resend.  Thanks.
