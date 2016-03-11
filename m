From: "Joseph Chang" <joseph_chang@davicom.com.tw>
Subject: RE: [PATCH 2/3] dm9601: manage eeprom to assure the chip for correct operation
Date: Fri, 11 Mar 2016 18:56:42 +0800
Message-ID: <201603111058.u2BAwUCT020098@mail.davicom.com.tw>
References: <87r3fimb7l.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="big5"
Content-Transfer-Encoding: 7bit
Cc: "'Peter Korsgaard'" <jacmet@sunsite.dk>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"'Joseph Chang'" <joseph_chang@davicom.com.tw>
To: "'Peter Korsgaard'" <peter@korsgaard.com>,
	"'Joseph CHANG'" <josright123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r3fimb7l.fsf@dell.be.48ers.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, this is to fixup purpose.

My customer buy "net101 USB20" netcards,
It was manifactured by some company and in the market.
We find it can not work due to eeprom wrong.

This fixup make it correct.
I focus on the essential eeprom words only.
Yes, need to reset the device once the eeprom is updated.
(I don't know how to let the device reset by software ?
 Only un-plug and then plug the device.)

Best Regards,
Joseph CHANG
System Application Engineering Division
Davicom Semiconductor, Inc.
No. 6 Li-Hsin 6th Rd., Science-Based Park,
Hsin-Chu, Taiwan.
Tel: 886-3-5798797 Ex 8534
Fax: 886-3-5646929
Web: http://www.davicom.com.tw


-----Original Message-----
From: Peter Korsgaard [mailto:jacmet@gmail.com] On Behalf Of Peter Korsgaard
Sent: Friday, March 11, 2016 2:37 AM
To: Joseph CHANG
Cc: Peter Korsgaard; netdev@vger.kernel.org; linux-usb@vger.kernel.org;
linux-kernel@vger.kernel.org; Joseph Chang
Subject: Re: [PATCH 2/3] dm9601: manage eeprom to assure the chip for correct
operation

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

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.
