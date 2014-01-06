From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v2 6/6] r8152: support RTL8153
Date: Mon, 06 Jan 2014 10:21:56 +0100
Message-ID: <87eh4l31or.fsf@nemi.mork.no>
References: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
	<1388633110-1435-1-git-send-email-hayeswang@realtek.com>
	<877gai8nqu.fsf@nemi.mork.no>
	<605671F106F540BA9665A195CACB78A0@realtek.com.tw>
	<8738l58pyd.fsf@nemi.mork.no>
	<AA7EB9EA13B74B14BBE08C4278F7948C@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <oliver@neukum.org>, <netdev@vger.kernel.org>,
	"'nic_swsd'" <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AA7EB9EA13B74B14BBE08C4278F7948C@realtek.com.tw>
	(hayeswang@realtek.com's message of "Mon, 6 Jan 2014 11:20:43 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> writes:
>  Bj=C3=B8rn Mork [mailto:bjorn@mork.no]=20
> [...]
>> Sorry, but then this makes even less sense.  The active USB
>> configuration is user selectable and you should make any of=20
>> them work if
>> possible.  Why can't the drivers figure out this at runtime?
>
> Excuse me. I have no idea about how to switch the configuration at
> the runtime ,and how to change the default configuration when a
> USB device is plugged. When a user select one of the configurations,
> he/she would wish to fix the configuration number after rebooting or
> after the dangle is unplugged and plugged again. For these reasons,
> this is the simple way which I could think. Maybe I choose the wrong
> method because I don't know how to satisfy the requests. May you
> provide me the relative information? Then, I could replace the curren=
t
> method. Thanks.

I apologise if I misunderstood you.  When you mentioned multiple
configurations, then I assumed it was a device similar to this one
(partial output from /sys/kernel/debug/usb/devices):

T:  Bus=3D03 Lev=3D01 Prnt=3D01 Port=3D03 Cnt=3D01 Dev#=3D  4 Spd=3D480=
  MxCh=3D 0
D:  Ver=3D 2.00 Cls=3Def(misc ) Sub=3D02 Prot=3D01 MxPS=3D64 #Cfgs=3D  =
2
P:  Vendor=3D1199 ProdID=3D68a2 Rev=3D 0.06
S:  Manufacturer=3DSierra Wireless, Incorporated
S:  Product=3DMC7710
S:  SerialNumber=3D358178040092316
C:  #Ifs=3D 6 Cfg#=3D 1 Atr=3De0 MxPwr=3D  0mA
I:  If#=3D 0 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D
E:  Ad=3D81(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D01(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:  If#=3D 2 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D
E:  Ad=3D82(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:  If#=3D 3 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D
E:  Ad=3D83(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D84(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D03(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:  If#=3D 8 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D
E:  Ad=3D85(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D86(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D04(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:  If#=3D19 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D
E:  Ad=3D87(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D88(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D05(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:  If#=3D20 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D
E:  Ad=3D89(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D8a(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D06(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
C:* #Ifs=3D 2 Cfg#=3D 2 Atr=3De0 MxPwr=3D  0mA
A:  FirstIf#=3D12 IfCount=3D 2 Cls=3D02(comm.) Sub=3D0e Prot=3D00
I:* If#=3D12 Alt=3D 0 #EPs=3D 1 Cls=3D02(comm.) Sub=3D0e Prot=3D00 Driv=
er=3Dcdc_mbim
E:  Ad=3D81(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
I:  If#=3D13 Alt=3D 0 #EPs=3D 0 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driv=
er=3Dcdc_mbim
I:* If#=3D13 Alt=3D 1 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driv=
er=3Dcdc_mbim
E:  Ad=3D82(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D01(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms


Here you can see 2 configurations, where cfg #2 is active using a class
driver.  This is what Linux will choose in this case because the first
interface of cfg #1 is vendor specific.  But an end user can change it
by writing to the bConfigurationValue sysfs attribute:

 nemi:/tmp# echo 1 > /sys/bus/usb/devices/3-4/bConfigurationValue


giving this result:

T:  Bus=3D03 Lev=3D01 Prnt=3D01 Port=3D03 Cnt=3D01 Dev#=3D  4 Spd=3D480=
  MxCh=3D 0
D:  Ver=3D 2.00 Cls=3Def(misc ) Sub=3D02 Prot=3D01 MxPS=3D64 #Cfgs=3D  =
2
P:  Vendor=3D1199 ProdID=3D68a2 Rev=3D 0.06
S:  Manufacturer=3DSierra Wireless, Incorporated
S:  Product=3DMC7710
S:  SerialNumber=3D358178040092316
C:* #Ifs=3D 6 Cfg#=3D 1 Atr=3De0 MxPwr=3D  0mA
I:* If#=3D 0 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqcserial
E:  Ad=3D81(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D01(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D 2 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqcserial
E:  Ad=3D82(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D 3 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqcserial
E:  Ad=3D83(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D84(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D03(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D 8 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqmi_wwan
E:  Ad=3D85(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D86(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D04(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D19 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqmi_wwan
E:  Ad=3D87(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D88(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D05(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D20 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D(none)
E:  Ad=3D89(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D8a(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D06(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
C:  #Ifs=3D 2 Cfg#=3D 2 Atr=3De0 MxPwr=3D  0mA
A:  FirstIf#=3D12 IfCount=3D 2 Cls=3D02(comm.) Sub=3D0e Prot=3D00
I:  If#=3D12 Alt=3D 0 #EPs=3D 1 Cls=3D02(comm.) Sub=3D0e Prot=3D00 Driv=
er=3D
E:  Ad=3D81(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
I:  If#=3D13 Alt=3D 0 #EPs=3D 0 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driv=
er=3D
I:  If#=3D13 Alt=3D 1 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driv=
er=3D
E:  Ad=3D82(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D01(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms


Exactly the same device, but now cfg #1 is active and a different set o=
f
drivers have bound to the interfaces.  This is possible because none of
the involved drivers disable the support for this device at build-time.
Instead they use the available interface descriptors for matching and
probing supported functions.

End users will of course normally not go around writing stuff to sysfs
attributes like this.  Creating an udev rule to select a specific
counfiguration when the device is plugged is more useful for normal
usage.

My point was that this sort of runtime configuration change should be
possible, assuming my understanding of the device layout is correct.
Which it isn't necessarily.  I don't have any such device and I haven't
seen any USB descriptor dump from one either.



Bj=C3=B8rn
