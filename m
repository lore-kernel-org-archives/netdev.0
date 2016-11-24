From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 14:10:36 -0500
Message-ID: <9e8ff5b4-1c72-3106-7821-73484de133c2@pobox.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161124190055.GA3642@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124190055.GA3642@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-24 02:00 PM, Greg KH wrote:
> On Thu, Nov 24, 2016 at 01:34:08PM -0500, Mark Lord wrote:
>> One thought:  bulk data streams are byte streams, not packets.
>> Scheduling on the USB bus can break up larger transfers across
>> multiple in-kernel buffers.  A "real" URB buffer on USB2 is max 512 bytes.
>> The driver is providing 16384-byte buffers, and assumes that data will
>> never spill over from one such buffer to the next.
>> Yet the observations here consistently show otherwise.
> 
> Wait, how do you know that data will not spill over?  What is making
> that guarantee?  Will the USB device send a "zero packet" in order to
> show that all of the "logical" data is now sent for this specific
> endpoint?  Is there some sort of "framing" that the device does with the
> USB data so that the driver "knows" where the end of packet is?

Exactly my point.

> Check the zero-packet stuff for this device, that's tripped up many a
> USB driver writer over the years, myself included.

I haven't tripped over it myself, but only because we were careful
to allow for such in the USB drivers I have worked on.

The r8152 driver just assumes it never happens.
