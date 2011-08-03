From: Jon Mason <jon.mason@myri.com>
Subject: Re: [net-next v2 17/71] myri*: Move the Myricom drivers
Date: Wed, 3 Aug 2011 14:37:50 -0500
Message-ID: <CAMaF-rPbeasT=GZTPXTfVkH8Af20cPJLK9cwpxhRB36JxD=81Q@mail.gmail.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-18-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAMaF-rOs_8=F1-nKMSR4kosNuoGUTE284MKtRvSQ-X2p5sb+rw@mail.gmail.com>
	<1312351360.2294.95.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44642 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1HCThv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 15:37:51 -0400
Received: by yxj19 with SMTP id 19so427413yxj.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 12:37:51 -0700 (PDT)
In-Reply-To: <1312351360.2294.95.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 3, 2011 at 1:02 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Mon, 2011-08-01 at 10:09 -0700, Jon Mason wrote:
>> On Sat, Jul 30, 2011 at 10:26 PM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > Move the Myricom drivers into drivers/net/ethernet/myricom/ and ma=
ke
>> > the necessary Kconfig and Makefile changes.
>>
>> Acked-by: Jon Mason <mason@myri.com>
>>
>> > CC: Andrew Gallatin <gallatin@myri.com>
>> > CC: Brice Goglin <brice@myri.com>
>> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> Jon-
>
> I made some minor changes to the Kconfig based on feedback from other=
s
> on other Kconfig's which made sense to apply to the other driver
> Kconfig's. =A0Here is the Kconfig:
>
> +config NET_VENDOR_MYRI
> + =A0 =A0 =A0 bool "Myricom devices"
> + =A0 =A0 =A0 depends on PCI && INET
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 If you have a network (Ethernet) card belonging to =
this class,
> say
> + =A0 =A0 =A0 =A0 Y and read the Ethernet-HOWTO, available from
> + =A0 =A0 =A0 =A0 <http://www.tldp.org/docs.html#howto>.
> +
> + =A0 =A0 =A0 =A0 Note that the answer to this question doesn't direc=
tly affect
> the
> + =A0 =A0 =A0 =A0 kernel: saying N will just cause the configurator t=
o skip all
> + =A0 =A0 =A0 =A0 the questions about Myricom cards. If you say Y, yo=
u will be
> asked for
> + =A0 =A0 =A0 =A0 your specific card in the following questions.
> +
> +if NET_VENDOR_MYRI
> +
> +config MYRI10GE
> + =A0 =A0 =A0 tristate "Myricom Myri-10G Ethernet support"
> + =A0 =A0 =A0 depends on PCI && INET
> + =A0 =A0 =A0 select FW_LOADER
> + =A0 =A0 =A0 select CRC32
> + =A0 =A0 =A0 select INET_LRO
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This driver supports Myricom Myri-10G Dual Protocol=
 interface
> in
> + =A0 =A0 =A0 =A0 Ethernet mode. If the eeprom on your board is not r=
ecent
> enough,
> + =A0 =A0 =A0 =A0 you will need a newer firmware image.
> + =A0 =A0 =A0 =A0 You may get this image or more information, at:
> +
> + =A0 =A0 =A0 =A0 <http://www.myri.com/scs/download-Myri10GE.html>
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here. =
The module
> + =A0 =A0 =A0 =A0 will be called myri10ge.
> +
> +config MYRI10GE_DCA
> + =A0 =A0 =A0 bool "Direct Cache Access (DCA) Support"
> + =A0 =A0 =A0 default y
> + =A0 =A0 =A0 depends on MYRI10GE && DCA && !(MYRI10GE=3Dy && DCA=3Dm=
)
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Say Y here if you want to use Direct Cache Access (=
DCA) in the
> + =A0 =A0 =A0 =A0 driver. =A0DCA is a method for warming the CPU cach=
e before data
> + =A0 =A0 =A0 =A0 is used, with the intent of lessening the impact of=
 cache
> misses.
> +
> +endif # NET_VENDOR_MYRI
>
> Let me know if these changes are ok and I can add your ACK.

Looks fine to me.

Thanks,
Jon
