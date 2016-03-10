From: Peter Korsgaard <peter@korsgaard.com>
Subject: Re: [PATCH 2/3] dm9601: manage eeprom to assure the chip for correct operation
Date: Thu, 10 Mar 2016 19:36:46 +0100
Message-ID: <87r3fimb7l.fsf@dell.be.48ers.dk>
References: <1457609038-3636-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joseph Chang <joseph_chang@davicom.com.tw>
To: Joseph CHANG <josright123@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34173 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbcCJSi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 13:38:57 -0500
In-Reply-To: <1457609038-3636-1-git-send-email-josright123@gmail.com> (Joseph
	CHANG's message of "Thu, 10 Mar 2016 19:23:58 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Joseph" == Joseph CHANG <josright123@gmail.com> writes:

 > Add to maintain variant eeprom adapters which may have not right
 > dm962x's format.

 > Signed-off-by: Joseph CHANG <josright123@gmail.com>

> +static void dm_render_begin(struct usbnet *dev)
 > +{
 > +	/* Render eeprom if need, WORD3 render, set D[15:14] 01b */
 > +	dm_eeprom_render(dev, 3, 0x4000, 0xc000);
 > +	/* Render eeprom if need, WORD7 render, clear D[10] */
 > +	dm_eeprom_render(dev, 7, 0x0000, 0x0400);
 > +	/* Render eeprom if need, WORD11 render, need 0x005a */
 > +	dm_eeprom_render(dev, 11, 0x005a, 0xffff);
 > +	/* Render eeprom if need, WORD12 render, need 0x0007 */
 > +	dm_eeprom_render(dev, 12, DM_EP3I_VAL, 0xffff);

With render I guess you mean something like fixup? I'm not sure we want
to do this automatically without an explicit action from the user.

How common are these adapters without valid eeprom? What happens if the
eeprom content isn't fixed?

Do we need to reset the device once the eeprom is updated?

-- 
Bye, Peter Korsgaard
