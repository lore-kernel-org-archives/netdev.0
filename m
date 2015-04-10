From: Daniel Mack <daniel@zonque.org>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is commented
 out
Date: Fri, 10 Apr 2015 12:21:58 +0200
Message-ID: <5527A446.8030202@zonque.org>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <5526B608.2080504@gmail.com> <5526CA87.2070204@free.fr> <5526CC5A.1080504@gmail.com> <5526D359.1050202@free.fr> <552798CD.70608@zonque.org> <55279F65.9090202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mason <slash.tmp@free.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49665 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933049AbbDJKWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 06:22:02 -0400
In-Reply-To: <55279F65.9090202@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2015 12:01 PM, Mason wrote:
> Daniel Mack wrote:

>> A company I used to work with ships various hardware models in
>> quantities which features this chip, and they're using the unpatched
>> mainline kernel version of the driver.

Meh. I just double-checked the references again and figured the final
verions of the hardware design featured a 8030 model, not 8035. Sorry
for that.

So there might be a difference, and maybe the 8035 needs special
treatment. Then again, Fabio said he has a 8035 working.

>>> Maybe on my PHY, writing BMCR_RESET to BMCR triggers a SW reset,
>>> while it triggers a HW reset on other boards?
>>
>> AFAIK, the chip does not do this, no. But even if it did,
> 
> Did you forget to finish that sentence? :-)

Even if it did, the kernel driver should still be able to set up the
device just fine.

>> I'd still go and check if there's anything in one of the chained
>> bootloaders that does some magic. One other thing that might give you a
>> hint is to manually pull the RESET line low for a short time right when
>> the kernel decompressor is started. That way, the kernel has to deal
>> with a device that has just seen a hardware reset. Just see if that
>> makes any difference.
> 
> I'd force a HW reset by jiggling the appropriate GPIO pin?
> Like you did in the at803x.c driver?

Yes. But that's just to gain more ideas where to look for, and possibly
find a pattern.



Daniel
