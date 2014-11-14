From: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Fri, 14 Nov 2014 11:56:36 +0100
Message-ID: <CA+icZUX6caBKnjMv6V_26y_-VNfDqkeXFXKJhDdQpZy7W4oofw@mail.gmail.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
	<1415120132.31049.11.camel@dcbw.local>
	<CA+icZUW2iRkoAK10ayJ9PFuFGWBQzKdFe+8mfd=8oKkAp1txtg@mail.gmail.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUW2iRkoAK10ayJ9PFuFGWBQzKdFe+8mfd=8oKkAp1txtg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 2:21 PM, Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Nov 4, 2014 at 5:55 PM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> On Tue, 2014-11-04 at 16:11 +0100, Sedat Dilek wrote:
>>> Hi,
>>>
>>> I wanted to understand what is going on the kernel-side when
>>> connecting to the Internet via a Huawei E173 USB web-stick (3rd
>>> Generation: UMTS / HSPA).
>>>
>>> Especially the correlation between the diverse USB/NET kernel-drivers
>>> and how the networking is setup.
>>
>
> [ Sitting in front of a foreign Windows machine ]
>
> [ CC Aleksander ]
>
> Hi Dan,
>
> sorry for the late (and short) response.
>
> AFAICS you have given a "skeleton" for a "usb-wwan-networking"
> documentation :-).
>
> Personally, I would like to take into account some kernel-config
> options and some more things.
>

I started with documenting...

I have still some difficulties in understanding USB WWAN Networking.
So, this is what I revealed...

##### USB: HUAWEI E173 3G/UMTS/HSPA INTERNET STICK

### USB-NETWORKING AND WWAN SETUP
CONFIG_USB_USBNET=m        <--- usb networking
CONFIG_USB_NET_CDCETHER=m  <--- usb-wwan (net) configuration
CONFIG_USB_SERIAL_WWAN=m   <--- usb-wwan (serial) configuration
CONFIG_USB_SERIAL_OPTION=m <--- usb-serial driver called "option"

### PPP OPTIONS
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPP_MULTILINK=y
CONFIG_PPP_ASYNC=m

Beyond the PPP options, I wanted to understand what
CONFIG_USB_NET_CDCETHER does and why I need it.
Can someone help?

Thanks.

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/usb/Kconfig#n189

P.S.: cdc_ether Kconfig option and checking my logs

>From [1]...
...
config USB_NET_CDCETHER
tristate "CDC Ethernet support (smart devices such as cable modems)"
depends on USB_USBNET
default y
help
 This option supports devices conforming to the Communication Device
 Class (CDC) Ethernet Control Model, a specification that's easy to
 implement in device firmware.  The CDC specifications are available
 from <http://www.usb.org/>.

 CDC Ethernet is an implementation option for DOCSIS cable modems
 that support USB connectivity, used for non-Microsoft USB hosts.
 The Linux-USB CDC Ethernet Gadget driver is an open implementation.
   This driver should work with at least the following devices:

   * Dell Wireless 5530 HSPA
     * Ericsson PipeRider (all variants)
   * Ericsson Mobile Broadband Module (all variants)
     * Motorola (DM100 and SB4100)
     * Broadcom Cable Modem (reference design)
   * Toshiba (PCX1100U and F3507g/F3607gw)
   * ...

 This driver creates an interface named "ethX", where X depends on
 what other networking devices you have in use.  However, if the
 IEEE 802 "local assignment" bit is set in the address, a "usbX"
 name is used instead.
...

>From my logs...

$ dmesg | egrep -i 'option|wwan|ppp|3-1.2|huawei|gsm|modem'
[    0.000000] please try 'cgroup_disable=memory' option if you don't
want memory cgroups
[    0.549498] PPP generic driver version 2.4.2
[    1.299059] usb 3-1.2: new high-speed USB device number 3 using ehci-pci
[    1.394084] usb 3-1.2: New USB device found, idVendor=12d1, idProduct=1436
[    1.394095] usb 3-1.2: New USB device strings: Mfr=4, Product=3,
SerialNumber=0
[    1.394100] usb 3-1.2: Product: HUAWEI Mobile
[    1.394103] usb 3-1.2: Manufacturer: HUAWEI Technology
[    2.115424] usb-storage 3-1.2:1.0: USB Mass Storage device detected
[    2.125026] usb-storage 3-1.2:1.1: USB Mass Storage device detected
[    2.125607] usb-storage 3-1.2:1.2: USB Mass Storage device detected
[    2.125888] usb-storage 3-1.2:1.3: USB Mass Storage device detected
[    2.126187] usb-storage 3-1.2:1.4: USB Mass Storage device detected
[    2.126461] usb-storage 3-1.2:1.5: USB Mass Storage device detected
[    2.127098] scsi host11: usb-storage 3-1.2:1.5
[    2.129370] usb-storage 3-1.2:1.6: USB Mass Storage device detected
[    2.131685] scsi host12: usb-storage 3-1.2:1.6
[    3.127317] scsi 11:0:0:0: CD-ROM            HUAWEI   Mass Storage
   2.31 PQ: 0 ANSI: 2
[    3.137589] scsi 12:0:0:0: Direct-Access     HUAWEI   SD Storage
   2.31 PQ: 0 ANSI: 2
[   13.500302] cdc_ether 3-1.2:1.1 wwan0: register 'cdc_ether' at
usb-0000:00:1a.0-1.2, Mobile Broadband Network Device,
02:50:f3:00:00:00
[   14.160221] usbcore: registered new interface driver option
[   14.160820] usbserial: USB Serial support registered for GSM modem (1-port)
[   14.160940] option 3-1.2:1.0: GSM modem (1-port) converter detected
[   14.163032] usb 3-1.2: GSM modem (1-port) converter now attached to ttyUSB0
[   14.163305] option 3-1.2:1.3: GSM modem (1-port) converter detected
[   14.163676] usb 3-1.2: GSM modem (1-port) converter now attached to ttyUSB1
[   14.163742] option 3-1.2:1.4: GSM modem (1-port) converter detected
[   14.165227] usb 3-1.2: GSM modem (1-port) converter now attached to ttyUSB2
[   72.877065] PPP BSD Compression module registered
[   72.881701] PPP Deflate Compression module registered
- EOT -
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
