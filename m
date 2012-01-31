From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH] smsc95xx: add macaddr module parameter
Date: Tue, 31 Jan 2012 19:17:11 +0100
Message-ID: <201201311917.12534.danny.kukawka@bisect.de>
References: <1328030433-12524-1-git-send-email-danny.kukawka@bisect.de> <20120131172731.03df5704@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Greg Kroah-Hartman" <gregkh@suse.de>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120131172731.03df5704@pyramind.ukuu.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dienstag, 31. Januar 2012, Alan Cox wrote:
> On Tue, 31 Jan 2012 18:20:33 +0100
>
> Danny Kukawka <danny.kukawka@bisect.de> wrote:
> > Added smsc95xx.macaddr module parameter to allow the user to
> > change the MAC address on boot if there was no MAC on the EEPROM.
>
> NAK. Please see the discussion on this and ifconfig hw for other devices.
>
> In summary - make the device refuse to ifconfig up without a valid
> address, allow it to come into existance without a valid address and then
> use ifconfig.
>
>
> Your patch also seems to break if there are several attached to a board.

There are already other kernel driver which allow to override the (hw) MAC 
address via a module parameter (macaddr): 
- KSZ8841/2 PCI network driver (drivers/net/ethernet/micrel/ksz884x.c)
- FEC Ethernet driver (drivers/net/ethernet/freescale/fec.c)
- Sun HappyMealEthernet(HME) 10/100baseT ethernet driver
  (drivers/net/ethernet/sun/sunhme.c)

By default the MAC from the module parameter get only assigned to the first 
device which got a random MAC (caused by missing EEPROM) before. If you have 
more than one device you can simply assign the MAC to a specific interface 
(e.g. use: macaddr=01:23:45:67:89:ab;eth0). If there are only devices with 
hardware MAC nothing will get changed.

Danny
