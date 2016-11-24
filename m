From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 19:42:53 +0100
Message-ID: <20161124184253.GA23483@kroah.com>
References: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
 <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Mark Lord <mlord@pobox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 24, 2016 at 11:43:53AM -0500, Mark Lord wrote:
> On 16-11-24 11:21 AM, David Miller wrote:
> > From: Hayes Wang <hayeswang@realtek.com>
> > Date: Thu, 24 Nov 2016 13:26:55 +0000
> > 
> > > I don't think the garbage results from our driver or device.
> > This is my impression with what has been presented so far as well.
> 
> It's not garbage.
> 
> The latest run with the debug code I posted here earlier just spat out this below.
> Using coherent (guarded, non-cacheable) RX buffers, with mb() calls:
> 
> [   15.199157] r8152_check_rx_desc: rx_desc looks bad.
> [   15.204270] r8152_rx_bottom: offset=0/3376 bad rx_desc
> [   15.209584] r8152_dump_rx_desc: 3d435253 3034336d 202f3a30 47524154 2f3d5445 3034336d rx_len=21075
> 
> The bad data in this case is ASCII:
> 
>         "SRC=m3400:/ TARGET=/m340"

Have you tried using usbmon?  Details for how to use it is in
Documentation/usbmon.txt and it might help you rule out the driver vs.
the USB host controller issues as it sees the raw data the USB host
controller sees before it sends it to the driver.

thanks,

greg k-h
