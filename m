From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Tue, 07 Aug 2007 18:15:47 -0400
Message-ID: <46B8EF13.40109@garzik.org>
References: <1185957077.5552.22.camel@dell> <200708020006.13457.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44734 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753813AbXHGWPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 18:15:53 -0400
In-Reply-To: <200708020006.13457.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Wednesday 01 August 2007 10:31:17 Michael Chan wrote:
>> +static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
>> +{
>> +	struct net_device *dev = dev_instance;
> 
> You need to check if dev==NULL and bail out.
> Another driver sharing the IRQ with this might choose to pass the dev
> pointer as NULL.

NAK that advice:  It is pointless having such a check in the hottest of 
driver hot paths, since a large majority of drivers do not have such a 
check.

It is better to fix the extremely rare oddball that passes NULL to 
request_irq(), than to update all drivers to be slower due to the oddballs.


>> +	struct bnx2x *bp = netdev_priv(dev);
> 
> No check if the device actually _did_ generate the IRQ? Sharing...

Not for MSI


>> +static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
>> +{
>> +
>> +	struct bnx2x_fastpath *fp = fp_cookie;
> 
> Check if fp==NULL

NAK

>> +	struct bnx2x *bp = fp->bp;
>> +	struct net_device *dev = bp->dev;
> 
> No share protection either?

MSI


>> +static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
>> +{
>> +	struct net_device *dev = dev_instance;
> 
> Check if dev==NULL

NAK


>> +	struct bnx2x *bp = netdev_priv(dev);
>> +	u16 status = bnx2x_ack_int(bp);
>> +
>> +	if (unlikely(status == 0)) {
> 
> That's not unlikely.

in this case, agreed

the other comments seem fairly sane, and indeed should be considered for 
the existing drivers as well.

	Jeff


