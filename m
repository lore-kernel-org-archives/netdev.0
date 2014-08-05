From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Subject: Re: [PATCH] net/usb/hso: Add support for Option GTM671WFS
Date: Tue, 5 Aug 2014 08:59:25 +0200
Message-ID: <CAPybu_19W1tvWVQrP_TN_rEw3LGAnSYgRvNp2DeFM_tKGAWF7w@mail.gmail.com>
References: <1407143509-27683-1-git-send-email-ricardo.ribalda@gmail.com>
 <CAPybu_0E3P0f0dXwx7Ak=ZduWHbRXVMh4SJf9q22Je6yc3AWNg@mail.gmail.com> <1407177057.9447.2.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jan Dumon <j.dumon@option.com>,
	Linux USB Mailing List <linux-usb@vger.kernel.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:52987 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756006AbaHEHFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:05:46 -0400
In-Reply-To: <1407177057.9447.2.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dan.

I have also been able to start/stop the gps via the gps control port
(ttyHS2) and get nmea data port through the gps port. (ttyHS1)

Please tell me if you need more tests

Regards!

root@qt5022:~# cat /sys/class/tty/*/hsotype
Diagnostic
GPS
GPS Control
Application
Control
Modem
root@qt5022:~# hso_connect up
Using /etc/conninfo.ini as connection file
Using /dev/ttyHS3 application port.
Initializing...
Trying internet ...
Connecting...
trying
Connected
Setting IP address to  10.198.XXX.115
Adding route
Done.
root@qt5022:~# ifconfig hso0
hso0      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          inet addr:10.198.XXX.115  P-t-P:10.198.XXX.115  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1486  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:10
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

root@qt5022:~# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=46 time=1163 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=46 time=304 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=46 time=72.5 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=46 time=60.7 ms
^C
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 60.790/400.296/1163.670/451.296 ms, pipe 2
root@qt5022:~# cat /dev/ttyHS1
$GPGSV,4,1,16,24,,,,27,,,,12,,,,32,,,*7A
$GPGSV,4,2,16,31,,,,30,,,,29,,,,28,,,*78
$GPGSV,4,3,16,26,,,,25,,,,23,,,,22,,,*7B
$GPGSV,4,4,16,21,,,,20,,,,19,,,,18,,,*7E
$GPGGA,,,,,,0,,,,,,,,*66
$PQXFI,,,,,,,,,,*56
$GPVTG,,T,,M,,N,,K,N*2C
$GPRMC,,V,,,,,,,,,,N*53
$GPGSA,A,1,,,,,,,,,,,,,,,*1E
$GPGSV,4,1,16,04,,,,24,,,,27,,,,12,,,*7F
$GPGSV,4,2,16,32,,,,31,,,,30,,,,29,,,*73
$GPGSV,4,3,16,28,,,,26,,,,25,,,,23,,,*71
$GPGSV,4,4,16,22,,,,21,,,,20,,,,19,,,*77
$GPGGA,,,,,,0,,,,,,,,*66
$PQXFI,,,,,,,,,,*56
$GPVTG,,T,,M,,N,,K,N*2C
$GPRMC,,V,,,,,,,,,,N*53
$GPGSA,A,1,,,,,,,,,,,,,,,*1E

On Mon, Aug 4, 2014 at 8:30 PM, Dan Williams <dcbw@redhat.com> wrote:
> On Mon, 2014-08-04 at 11:20 +0200, Ricardo Ribalda Delgado wrote:
>> Suggested-by: Dan Williams <dcbw@redhat.com>
>
> Before we apply this patch though, can you grab for the following for
> me?
>
> cat /sys/class/tty/*/hsotype
>
> and lets see if the firmware actually responds.  Also, do you get an
> 'hso0' network interface as reported by ifconfig or /sbin/ip?  If you
> do, then lets do some additional verification to ensure it should be
> driven by 'hso' instead of option.
>
> Dan
>
>> On Mon, Aug 4, 2014 at 11:11 AM, Ricardo Ribalda Delgado
>> <ricardo.ribalda@gmail.com> wrote:
>> > After this patch:
>> >
>> > [ 32.985530] hso: drivers/net/usb/hso.c: Option Wireless
>> > [ 33.000452] hso 2-1.4:1.7: Not our interface
>> > [ 33.001849] usbcore: registered new interface driver hso
>> >
>> > root@qt5022:~# ls /dev/ttyHS*
>> > /dev/ttyHS0  /dev/ttyHS1  /dev/ttyHS2  /dev/ttyHS3  /dev/ttyHS4
>> > /dev/ttyHS5
>> >
>> > root@qt5022:~# lsusb -d 0af0: -vvv
>> >
>> > Bus 002 Device 003: ID 0af0:9200 Option
>> > Device Descriptor:
>> >   bLength                18
>> >   bDescriptorType         1
>> >   bcdUSB               2.00
>> >   bDeviceClass          255 Vendor Specific Class
>> >   bDeviceSubClass       255 Vendor Specific Subclass
>> >   bDeviceProtocol       255 Vendor Specific Protocol
>> >   bMaxPacketSize0        64
>> >   idVendor           0x0af0 Option
>> >   idProduct          0x9200
>> >   bcdDevice            0.00
>> >   iManufacturer           3 Option N.V.
>> >   iProduct                2 Globetrotter HSUPA Modem
>> >   iSerial                 0
>> >   bNumConfigurations      1
>> >   Configuration Descriptor:
>> >     bLength                 9
>> >     bDescriptorType         2
>> >     wTotalLength          200
>> >     bNumInterfaces          8
>> >     bConfigurationValue     1
>> >     iConfiguration          1 Option Configuration
>> >     bmAttributes         0xe0
>> >       Self Powered
>> >       Remote Wakeup
>> >     MaxPower              100mA
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        0
>> >       bAlternateSetting       0
>> >       bNumEndpoints           2
>> >       bInterfaceClass       255 Vendor Specific Class
>> >       bInterfaceSubClass    255 Vendor Specific Subclass
>> >       bInterfaceProtocol    255 Vendor Specific Protocol
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x81  EP 1 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x01  EP 1 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        1
>> >       bAlternateSetting       0
>> >       bNumEndpoints           2
>> >       bInterfaceClass       255 Vendor Specific Class
>> >       bInterfaceSubClass    255 Vendor Specific Subclass
>> >       bInterfaceProtocol    255 Vendor Specific Protocol
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x82  EP 2 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x02  EP 2 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        2
>> >       bAlternateSetting       0
>> >       bNumEndpoints           2
>> >       bInterfaceClass       255 Vendor Specific Class
>> >       bInterfaceSubClass    255 Vendor Specific Subclass
>> >       bInterfaceProtocol    255 Vendor Specific Protocol
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x83  EP 3 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x03  EP 3 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        3
>> >       bAlternateSetting       0
>> >       bNumEndpoints           2
>> >       bInterfaceClass       255 Vendor Specific Class
>> >       bInterfaceSubClass    255 Vendor Specific Subclass
>> >       bInterfaceProtocol    255 Vendor Specific Protocol
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x84  EP 4 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x04  EP 4 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        4
>> >       bAlternateSetting       0
>> >       bNumEndpoints           2
>> >       bInterfaceClass       255 Vendor Specific Class
>> >       bInterfaceSubClass    255 Vendor Specific Subclass
>> >       bInterfaceProtocol    255 Vendor Specific Protocol
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x85  EP 5 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x05  EP 5 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        5
>> >       bAlternateSetting       0
>> >       bNumEndpoints           2
>> >       bInterfaceClass       255 Vendor Specific Class
>> >       bInterfaceSubClass    255 Vendor Specific Subclass
>> >       bInterfaceProtocol    255 Vendor Specific Protocol
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x06  EP 6 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x86  EP 6 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        6
>> >       bAlternateSetting       0
>> >       bNumEndpoints           3
>> >       bInterfaceClass       255 Vendor Specific Class
>> >       bInterfaceSubClass    255 Vendor Specific Subclass
>> >       bInterfaceProtocol    255 Vendor Specific Protocol
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x87  EP 7 IN
>> >         bmAttributes            3
>> >           Transfer Type            Interrupt
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0040  1x 64 bytes
>> >         bInterval               5
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x88  EP 8 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x07  EP 7 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval              32
>> >     Interface Descriptor:
>> >       bLength                 9
>> >       bDescriptorType         4
>> >       bInterfaceNumber        7
>> >       bAlternateSetting       0
>> >       bNumEndpoints           2
>> >       bInterfaceClass         8 Mass Storage
>> >       bInterfaceSubClass      6 SCSI
>> >       bInterfaceProtocol     80 Bulk-Only
>> >       iInterface              0
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x08  EP 8 OUT
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval               1
>> >       Endpoint Descriptor:
>> >         bLength                 7
>> >         bDescriptorType         5
>> >         bEndpointAddress     0x89  EP 9 IN
>> >         bmAttributes            2
>> >           Transfer Type            Bulk
>> >           Synch Type               None
>> >           Usage Type               Data
>> >         wMaxPacketSize     0x0200  1x 512 bytes
>> >         bInterval               1
>> > Device Qualifier (for other device speed):
>> >   bLength                10
>> >   bDescriptorType         6
>> >   bcdUSB               2.00
>> >   bDeviceClass          255 Vendor Specific Class
>> >   bDeviceSubClass       255 Vendor Specific Subclass
>> >   bDeviceProtocol       255 Vendor Specific Protocol
>> >   bMaxPacketSize0        64
>> >   bNumConfigurations      1
>> > Device Status:     0x0001
>> >   Self Powered
>> >
>> > Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
>> > ---
>> >  drivers/net/usb/hso.c | 1 +
>> >  1 file changed, 1 insertion(+)
>> >
>> > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
>> > index a3a0586..eb12261 100644
>> > --- a/drivers/net/usb/hso.c
>> > +++ b/drivers/net/usb/hso.c
>> > @@ -469,6 +469,7 @@ static const struct usb_device_id hso_ids[] = {
>> >         {USB_DEVICE(0x0af0, 0x8800)},
>> >         {USB_DEVICE(0x0af0, 0x8900)},
>> >         {USB_DEVICE(0x0af0, 0x9000)},
>> > +       {USB_DEVICE(0x0af0, 0x9200)},           /* Option GTM671WFS */
>> >         {USB_DEVICE(0x0af0, 0xd035)},
>> >         {USB_DEVICE(0x0af0, 0xd055)},
>> >         {USB_DEVICE(0x0af0, 0xd155)},
>> > --
>> > 2.0.1
>> >
>>
>>
>>
>
>



-- 
Ricardo Ribalda
