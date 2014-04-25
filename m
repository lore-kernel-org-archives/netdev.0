From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: Porting ethernet over spi driver (powerline device)
Date: Fri, 25 Apr 2014 09:24:57 +0200
Message-ID: <535A0DC9.8060102@i2se.com>
References: <5350ED9E.6080103@lategoodbye.de>	 <1398133328.3624.186.camel@deadeye.wl.decadent.org.uk>	 <53563E3C.3030108@i2se.com> <1398180075.3624.191.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stefan Wahren <info@lategoodbye.de>, netdev@vger.kernel.org,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.130]:50845 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbaDYHZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 03:25:04 -0400
In-Reply-To: <1398180075.3624.191.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.04.2014 17:21, schrieb Ben Hutchings:
> On Tue, 2014-04-22 at 12:02 +0200, Stefan Wahren wrote:
>> Am 22.04.2014 04:22, schrieb Ben Hutchings:
> [..]
>>> Most of the interesting new features are related to multiqueue and
>>> protocol offloads that I wouldn't expect to exist in an SPI-attached
>>> Ethernet controller.  
>> You are right.
>>
>> Btw, is simple power management (suspend, resume) a must-have feature?
> If you're intending to get the driver in-tree, I don't think those are
> an absolute requirement but I would certainly recommend implementing
> them.
>
> Ben.
>

Yes, that's my intension. The QCA7000 isn't a typical ethernet over spi
device, it's a serial-to-powerline bridge. Acting like a ethernet over
spi device simplifies the implementation. This leads to an important
question.

Should the QCA7000 be handled strict as an ethernet device or a little
bit more distinguished as a powerline device?

I think that would have influence on the following aspects:

* Interface naming scheme in user space

Currently the interface has the interface pattern qca%d instead of
eth%d. I think this won't be acceptable for in-tree. But the interface
pattern pwl%d for powerline could also be possible.

* Node name in devicetree sources

Currently the node is named as qca7000, but from my understanding it's
should be ethernet or powerline.

* Driver directory in kernel sources

In my development i store the sources under drivers/net/ethernet. But
for in-tree i see the following candidates:

drivers/net/ethernet/qca/
drivers/net/ethernet/qualcomm/
drivers/net/powerline/qca/

Any suggestions?

Kind regards
Stefan Wahren
