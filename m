From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Fri, 6 Jan 2012 00:50:41 +0100
Message-ID: <CAHXqBF+ZY-KH8hOi+QnDZVHx+8OOqP5CLXR44YtDLB3=1DDEOA@mail.gmail.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
 <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
 <1325788584.3764.28.camel@bwh-desktop> <F6FB0E698C9B3143BDF729DF22286646027184@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933024Ab2AEXvC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 18:51:02 -0500
Received: by iaeh11 with SMTP id h11so1657162iae.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 15:51:02 -0800 (PST)
In-Reply-To: <F6FB0E698C9B3143BDF729DF22286646027184@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/5 Skidmore, Donald C <donald.c.skidmore@intel.com>:
>>-----Original Message-----
>>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>>Sent: Thursday, January 05, 2012 10:36 AM
>>To: Skidmore, Donald C
>>Cc: Michal Miroslaw; Kirsher, Jeffrey T; davem@davemloft.net;
>>netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com;
>>Waskiewicz Jr, Peter P
>>Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal da=
ta
>>
>>On Thu, 2012-01-05 at 17:53 +0000, Skidmore, Donald C wrote:
>>> >-----Original Message-----
>>> >From: Micha=B3 Miros=B3aw [mailto:mirqus@gmail.com]
>>> >Sent: Friday, December 23, 2011 9:59 AM
>>> >To: Kirsher, Jeffrey T
>>> >Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.or=
g;
>>> >gospo@redhat.com; sassmann@redhat.com; Waskiewicz Jr, Peter P
>>> >Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal
>>data
>>> >
>>> >2011/12/23 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
>>> >> From: Don Skidmore <donald.c.skidmore@intel.com>
>>> >>
>>> >> Some of our adapters have thermal data available, this patch
>>exports
>>> >this
>>> >> data via a read-only sysfs interface.
>>> >
>>> >Just curious: can't this use the hwmon subsystem to be consistent
>>with
>>> >other system monitoring devices?
>>> >
>>> >Best Regards,
>>> >Micha=B3 Miros=B3aw
>>>
>>> Sorry about the slow response, first vacation then I hadn't heard o=
f
>>> hwmon and wanted to look into it a bit. =A0I can see why you mentio=
ned
>>> it as it looks to be close to what I'm trying to do here. =A0Howeve=
r I
>>> don't think it quite matches. =A0I'll list my thoughts below:
>>>
>>> - We are trying to export a large set of data that our customers ar=
e
>>> requesting. =A0The thermals were just the first patch and the other=
 data
>>> items wouldn't really fit well in the hwmon (i.e. FW version,
>>> secondary MAC address).
>>
>>Nevertheless, there is a specific way that the thermal information
>>should be exposed.
>>
>>> - Didn't seem like we had much data to offer hwmon anyway just sens=
or
>>> temp, caution threshold, maxop threshold and location of sensor. =A0=
All
>>> the other data (which you haven't seen yet so couldn't have known :=
)
>>> wasn't related.
>>> - The thermal data we do have is defined in our FW and could change
>>> (number of sensors) based on that FW. =A0I wasn't sure whether that
>>> would be an issue for hwmon.
>>
>>I have the same issue with the current Solarflare controllers, as the
>>driver has no static information about specific boards. =A0It is poss=
ible
>>to generate hwmon attributes dynamically though I've not yet got roun=
d
>>to completing my implementation of this. =A0(Since firmware is also
>>responsible for thermal shutdown, handling any of this stuff in the
>>driver has been a low priority.)
>>
>>> - I went with sysfs based on a conversation with Peter Waskiewicz. =
=A0He
>>> mentioned that there was discussion on how to export generic data a=
t
>>> netconf and sysfs was brought up as the best choice.
>>
>>Sensors are also exposed through sysfs, but following a specific nami=
ng
>>convention and using a separate hwmon device.
>>
>>(Oddly, though, the sensor attributes are must be attached to the hwm=
on
>>device's parent - which will be your PCI device. =A0So you may not ne=
ed to
>>make many changes.)
>>
>>Ben.
>>
>
> Hey Ben,
>
> Thanks for all the clarifications. =A0I think I have a better idea wh=
at would be required from an hwmon interface.
>
> My one real concern with this implementation is that the ixgbe driver=
 will now have a dependency on hwmon. =A0The customers that are request=
ing this data aren't interested in using hwmon and would most likely ju=
st grab the thermal information (which is a small portion of the data t=
hey are asking for us to export) directly from sysfs. =A0Originally the=
y wanted the FW to export the data directly, when this was found to be =
impossible the driver became the fall back option.
>
> I do see your point on this being a defined way to expose thermals an=
d I want to do this the correct way. =A0It just seems to put a lot of o=
verhead on the driver (dependence on hwmon) for 4 fields that the user =
of this data won't even be using hwmon to look at. =A0I guess I would f=
eel better if we had more data to provide hwmon then its support would =
seem more useful.

Drivers outside of drivers/hwmon just select HWMON in Kconfig. This
adds a 3kB .c file to the kernel build for the first one that needs
it.

Best Regards,
Micha=B3 Miros=B3aw
