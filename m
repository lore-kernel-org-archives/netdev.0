From: "Joseph Chang" <joseph_chang@davicom.com.tw>
Subject: RE: [PATCH 3/3] dm9601: add support ethtool style utility
Date: Fri, 11 Mar 2016 19:08:57 +0800
Message-ID: <201603111110.u2BBAiwV020429@mail.davicom.com.tw>
References: <1457615865.3001.36.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
To: "'Ben Hutchings'" <ben@decadent.org.uk>,
	"'Joseph Chang'" <joseph_chang@davicom.com.tw>,
	"'Joseph CHANG'" <josright123@gmail.com>,
	"'Peter Korsgaard'" <jacmet@sunsite.dk>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.davicom.com.tw ([60.250.193.73]:55645 "EHLO
	mail.davicom.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbcCKLLH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 06:11:07 -0500
In-Reply-To: <1457615865.3001.36.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tested by
 ./ethtool -E eth0 magic 0x9620 offset 0 length 3 value 0xf1 value 0xf2 value 0xf3

I think ethtool need [ value N ] for each byte (so need three "value xx" in above command line), 
am I right?

Oh, I can see it goes wrong~ Thanks~

* I will go a vacation from now on, this issue will be study later.
 Any helpful reference implementation data is appreciated. 
 
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
From: Ben Hutchings [mailto:ben@decadent.org.uk] 
Sent: Thursday, March 10, 2016 9:18 PM
To: Joseph Chang; 'Joseph CHANG'; 'Peter Korsgaard'; netdev@vger.kernel.org; linux-usb@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] dm9601: add support ethtool style utility

On Thu, 2016-03-10 at 20:51 +0800, Joseph Chang wrote:
> I did verify to dump EEPROM data and also write EEPROM by per byte.
> 
> 1.Plug dm9601/dm9621 adapter and has get dm9601.ko be 'insmod' to have 'eht0',
> 2.Run ethtool v3.7 (as attached executable file and it's help display.)
> 3. Commands:
>    ./ethtool -e eth0  (dump EEPROM data for all the .get_eeprom_len )
>    ./ethtool -E eth0 magic 0x9620 offset 0 value 0xf1  (write 0xf1 to eeprom byte0)
>    ./ethtool -E eth0 magic 0x9620 offset 1 value 0xf2  (write 0xf2 to eeprom byte1)
>    ./ethtool -E eth0 magic 0x9620 offset 2 value 0xf3  (write 0xf3 to eeprom byte2)
[...]

So you only tested writing 1 byte at a time.  Try again with 3 bytes
and you'll see how it goes wrong.

Ben.

-- 
Ben Hutchings
To err is human; to really foul things up requires a computer.
