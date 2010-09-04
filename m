From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH] [RFC] introduce cx82310_eth: Conexant CX82310-based ADSL
 router USB ethernet driver
Date: Sat, 04 Sep 2010 17:12:50 +0100
Message-ID: <4C827002.6060808@simon.arlott.org.uk>
References: <201009032317.14954.linux@rainbow-software.org> <4C81735E.3030903@simon.arlott.org.uk> <201009041357.26215.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:42447 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753538Ab0IDQM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 12:12:57 -0400
In-Reply-To: <201009041357.26215.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/10 12:57, Ondrej Zary wrote:
> On Saturday 04 September 2010 00:14:54 Simon Arlott wrote:
>> On 03/09/10 22:17, Ondrej Zary wrote:
>> > +	/* send command packet */
>> > +	ret = usb_bulk_msg(udev, usb_sndbulkpipe(udev, CMD_EP), buf,
>> > +			   CMD_PACKET_SIZE, &actual_len, CMD_TIMEOUT);
>>
>> From your previous lsusb output this is an interrupt endpoint, although
>> usb_bulk_msg will auto-detect the type.
> 
> There's also usb_interrupt_msg() function but it calls usb_bulk_msg() directly 
> so it probably does not matter...
> Otherwise, I already found out that sending interrupt URBs to bulk endpoints 
> is a very bad idea (when programming Nexio support for usbtouchscreen). Alan 
> Stern then created a patch that checks for this.

I know... it broke cxacru when the device has a bulk command endpoint.

>> >
>> > +#define rx_incomplete	(dev->data[0])
>> > +#define rx_remainder	(dev->data[1])
>> > +#define incomplete_data	(dev->data[2])
>>
>> This doesn't make the rest of the code particularly readable.
> 
> I agree. Maybe I should abuse data[0] as a pointer to private data...
> This data[] array does not seem like a good thing. Various usbnet drivers 
> abuse it in various ways. It should probably be removed and replaced by one 
> priv pointer.

There's driver_priv, added in 2008 and used only by rndis_wlan.

>> > +	/* we can send at most 1514 bytes of data (+ 2-byte header) per URB */
>> > +	dev->hard_mtu = CX82310_MTU + dev->net->hard_header_len;
>>
>> Have you tried sending larger packets?
>> With another 8 bytes it would support 802.1Q (VLAN).
> 
> Larger packets seem to be dropped. No surprise as the router firmware does not 
> support VLANs either.

I hadn't considered that it'd need to be able to receive/transmit the
larger packets over the built-in ethernet ports too.

-- 
Simon Arlott
