From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Wed, 20 Jul 2016 11:33:43 -0400
Message-ID: <wrfjk2ggpbmw.fsf@redhat.com>
References: <20160719153403.2967812-1-arnd@arndb.de>
 <4806848.QL77nxBrs4@wuerfel> <wrfjlh0wsg9s.fsf@redhat.com>
 <3876342.AU5AfU16PB@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org,
 Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
 Andrea Merello <andrea.merello@gmail.com>, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Kalle Valo <kvalo@codeaurora.org>, Larry Finger <Larry.Finger@lwfinger.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <3876342.AU5AfU16PB@wuerfel> (Arnd Bergmann's message of "Wed, 20
 Jul 2016 17:12:09 +0200")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:
> On Wednesday, July 20, 2016 7:25:19 AM CEST Jes Sorensen wrote:
>> Arnd Bergmann <arnd@arndb.de> writes:
>> Well it really all depends on how much time I have and how much others
>> step up and help contribute to the code. For rtl8xxxu my plans are as
>> follows:
>> 
>> 1) rtl8188eu support, since this is the most widely distributed USB
>> dongle which isn't currently supported by a non staging driver. I am
>> currently working on this together with Andrea Merello.
>
> Ok, cool.
>
>> 2) Beacon support for IBSS and AP mode - hopefully this should make it
>> possible to default rtl8xxxu for rtl8192cu/rtl8188cu devices and disable
>> them in rtlwifi.
>
> Do we have any indication that those two actually work in rtlwifi at the
> moment? My experience seems to match the recommendations for all the
> raspberry pi users that use yet another (worse looking) driver:
>
> https://github.com/raspberrypi/linux/commit/9ee31007a5032a3afe2fcb20c36b34f0ad57df56

I am not really authoritative on that one. I tried it in station mode
and it didn't work well for me. I never played with AP mode - It may
work better in IBSS or AP mode than it does in station mode. I don't
like to pull the rug away under people, which is why I haven't pushed
for this.

>> > As one data point that I can provide (but you are probably
>> > aware of), I could never get my rtl8188cus stick to work with
>> > rtlwifi, but I found the older r8712u device to work fine with
>> > the staging/rtl8712 driver.
>> 
>> I'd love to hear if the rtl8188cus works better with rtl8xxxu.
>
> It took me far too long to get the driver running on my machine (all my fault),
> but I've tested it now. Unfortunately there is something very wrong
> with my home wireless network at the moment, so I can only confirm
> that it doesn't work any worse than my Intel Wireless card on 2.4GHz,
> but that isn't any good (5GHz devices are fine, but that doesn't
> help on a 2.4GHz-only device).
>
> This is what I see in the kernel log
>
> [  773.862848] usb 2-1.2: new high-speed USB device number 8 using ehci-pci
> [  773.957415] usb 2-1.2: New USB device found, idVendor=0bda, idProduct=8176
> [ 773.957425] usb 2-1.2: New USB device strings: Mfr=1, Product=2,
> SerialNumber=3
> [  773.957430] usb 2-1.2: Manufacturer: Realtek
> [  773.957433] usb 2-1.2: SerialNumber: 00e04c000001
> [  774.115182] usb 2-1.2: Vendor: Realtek
> [  774.115192] usb 2-1.2: Product: 
> [  774.115199] usb 2-1.2: rtl8192cu_parse_efuse: dumping efuse (0x80 bytes):
> [  774.115206] usb 2-1.2: 00: 29 81 00 74 ed 00 00 00
> [  774.115212] usb 2-1.2: 08: ff 00 da 0b 76 81 01 41
> [  774.115219] usb 2-1.2: 10: 32 00 85 62 7e ad 5c f3
> [  774.115225] usb 2-1.2: 18: 70 15 9c b1 0a 03 52 65
> [  774.115231] usb 2-1.2: 20: 61 6c 74 65 6b 00 02 03
> [  774.115237] usb 2-1.2: 28: 00 00 00 00 00 00 00 00
> [  774.115242] usb 2-1.2: 30: 00 00 00 00 00 00 00 00
> [  774.115248] usb 2-1.2: 38: 00 00 00 00 00 00 00 00
> [  774.115254] usb 2-1.2: 40: 00 00 00 00 00 00 00 00
> [  774.115260] usb 2-1.2: 48: 00 00 00 00 00 00 00 00
> [  774.115265] usb 2-1.2: 50: 00 00 00 00 00 00 00 00
> [  774.115271] usb 2-1.2: 58: 06 00 2a 2a 2a 00 00 00
> [  774.115277] usb 2-1.2: 60: 2a 2a 2a 00 00 00 00 00
> [  774.115283] usb 2-1.2: 68: 00 00 00 00 04 04 04 00
> [  774.115289] usb 2-1.2: 70: 00 00 00 00 00 00 05 00
> [  774.115295] usb 2-1.2: 78: 10 00 00 00 36 00 00 00
> [ 774.115302] usb 2-1.2: RTL8188CU rev A (TSMC) 1T1R, TX queues 2,
> WiFi=1, BT=0, GPS=0, HI PA=0
> [  774.115308] usb 2-1.2: RTL8188CU MAC: 5c:f3:70:15:9c:b1
> [ 774.115314] usb 2-1.2: rtl8xxxu: Loading firmware
> rtlwifi/rtl8192cufw_TMSC.bin
> [  774.115409] usb 2-1.2: Firmware revision 80.0 (signature 0x88c1)
> [  775.692344] rtl8xxxu 2-1.2:1.0 wlan1: renamed from wlan0
> [  775.721151] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
> [  775.746653] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
> [  775.798780] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
> [  788.414618] wlan2: authenticate with 22:4e:7f:6f:5b:3c
> [  788.452485] wlan2: send auth to 22:4e:7f:6f:5b:3c (try 1/3)
> [  788.457926] wlan2: authenticated
> [  788.462261] wlan2: associate with 22:4e:7f:6f:5b:3c (try 1/3)
> [ 788.475159] wlan2: RX AssocResp from 22:4e:7f:6f:5b:3c (capab=0x431
> status=0 aid=1)
> [  788.504683] wlan2: associated

That all looks reasonable to me.

> throughput for me is 2mbit/s, compared to my intel 2x2 wireless that gets
> 5mbit/s on the same network, but I guess that doesn't really mean much
> as long as I have problems with the infrastructure.

:) Note the rtl8xxxu driver doesn't report speeds properly to
NetworkMangler or 'iw' as the API for this relies on confirmed TX
speeds, and I only have an easy way of retrieving RX speeds from the RTL
device. The vendor driver probably fakes it.

> rtl8xxxu  IEEE 802.11  ESSID:"openwrt24-ab"  
>           Mode:Managed  Frequency:2.462 GHz  Access Point: 22:4E:7F:6F:5B:3C   
>           Bit Rate=54 Mb/s   Tx-Power=20 dBm   
>           Retry short limit:7   RTS thr=2347 B   Fragment thr:off
>           Power Management:off
>           Link Quality=47/70  Signal level=-63 dBm  
>           Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
>           Tx excessive retries:0  Invalid misc:38   Missed beacon:0
>
> iwlwifi   IEEE 802.11  ESSID:"openwrt24-ab"  
>           Mode:Managed  Frequency:2.462 GHz  Access Point: 22:4E:7F:6F:5B:3C   
>           Bit Rate=54 Mb/s   Tx-Power=15 dBm   
>           Retry short limit:7   RTS thr:off   Fragment thr:off
>           Power Management:on
>           Link Quality=65/70  Signal level=-45 dBm  
>           Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
>           Tx excessive retries:90  Invalid misc:146   Missed beacon:0
>
>
>> For the rtl8712 device, rtl8192su?, then potentially that could be added to
>> rtl8xxxu as well, but it's not a top priority on my list right now.
>
> This one:
> Bus 001 Device 033: ID 0bda:8171 Realtek Semiconductor Corp. RTL8188SU
> 802.11n WLAN Adapter
>
> I bought the rtl8188su a while ago, while the rtl8188cus (0bda:8176)
> is from this year. According to https://wikidevi.com/wiki/Realtek, it
> seems to be one year older than the rtl8188cus and was almost as common
> in its day. Apparently everyone that used to make ...su device replaced it
> with a ...cu or the newer ...eu chips and that is all you can buy these days
> on the low end.

Gotcha, 8188su is the 1x1 version of it. I do have a 8192su in the
drawer somewhere, but the TODO list is a bit long already :)

Cheers,
Jes
