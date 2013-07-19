From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [RFC] qlcnic: Enhance ethtool to display board temperature.
Date: Fri, 19 Jul 2013 17:59:52 +0000
Message-ID: <ADFE82A996F10145934E45547759F763311A2651@avmb3.qlogic.org>
References: <1374206237-27233-1-git-send-email-himanshu.madhani@qlogic.com>
 <51E9560F.7070902@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:39004
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753054Ab3GSSPC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jul 2013 14:15:02 -0400
In-Reply-To: <51E9560F.7070902@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Rick Jones [mailto:rick.jones2@hp.com]
> Sent: Friday, July 19, 2013 8:07 AM
> To: Himanshu Madhani
> Cc: netdev; David Miller; Dept-NX Linux NIC Driver
> Subject: Re: [RFC] qlcnic: Enhance ethtool to display board temperature.
> 
> On 07/18/2013 08:57 PM, Himanshu Madhani wrote:
> > From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> >
> > We need to provide a mechanism for a user space application to query
> > adapter temperature. This RFC patch is to request input on which of
> > the following approach would be appropriate way to export this
> information.
> >
> > Here are the two approaches that I am exploring. Please review and
> > provide your recommendation.
> >
> > 1. Enhance ethtool to add capability for driver to advertise its
> >     board temperature as part of "ethtool -i <ethX>"
> >
> >      For example, following would be output for an interface which
> >      has board temperature field populated via ethtool
> >
> >      "#ethtool -i p10p1"
> >      driver: qlcnic
> >      version: 5.2.44
> >      bus-info: 0000:08:00.0
> >      supports-statistics: yes
> >      supports-test: yes
> >      supports-eeprom-access: yes
> >      supports-register-dump: yes
> >      supports-priv-flags: no
> >      board-temperature: 34
> >
> >      There will be update required for ethtool.c in the repository
> >      git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
> >      maintained by Ben Hutchings.
> >
> >      if we decide to go with ethtool modification approach, I will send
> >      patch to update ethtool repository. Attached patch at the end of this
> >      email is for driver implementation for this approach.
> >
> > 2. Add a sysfs hook "brd_temp" which will be used by the application
> >     to query board temperature specific to the particular interface
> >
> >     for example, driver with "brd_temp" sysfs hook will show
> > temperature
> >
> >     "#cat /sys/class/net/p10p1/device/brd_temp"
> >     34
> 
> Is it at all likely that other I/O cards have similar temperature sensors?  If so,
> then perhaps a more generic I/O card location would be better?  Looking for
> "temp" under /sys on my 3.5 system I see:
> 
> /sys/bus/platform/devices/coretemp.0
> /sys/bus/platform/drivers/coretemp
> /sys/bus/platform/drivers/coretemp/coretemp.0
> /sys/devices/pci0000:00/0000:00:03.0/0000:0f:00.0/hwmon/hwmon0/temp1
> _input
> /sys/devices/platform/hp-wmi/hddtemp
> /sys/devices/platform/coretemp.0
> /sys/devices/platform/coretemp.0/temp3_input
> /sys/devices/platform/coretemp.0/temp3_label
> /sys/devices/platform/coretemp.0/temp2_crit_alarm
> /sys/devices/platform/coretemp.0/temp2_crit
> /sys/devices/platform/coretemp.0/temp3_crit
> /sys/devices/platform/coretemp.0/temp4_crit
> /sys/devices/platform/coretemp.0/temp5_crit
> /sys/devices/platform/coretemp.0/temp4_input
> /sys/devices/platform/coretemp.0/temp4_label
> /sys/devices/platform/coretemp.0/temp3_crit_alarm
> /sys/devices/platform/coretemp.0/temp4_crit_alarm
> /sys/devices/platform/coretemp.0/temp5_input
> /sys/devices/platform/coretemp.0/temp5_label
> /sys/devices/platform/coretemp.0/temp5_crit_alarm
> /sys/devices/platform/coretemp.0/temp2_max
> /sys/devices/platform/coretemp.0/temp3_max
> /sys/devices/platform/coretemp.0/temp4_max
> /sys/devices/platform/coretemp.0/temp5_max
> /sys/devices/platform/coretemp.0/temp2_input
> /sys/devices/platform/coretemp.0/temp2_label
> /sys/module/coretemp
> /sys/module/coretemp/drivers/platform:coretemp
> 
> 
> Anyhow, it seems that one of your peers presently puts that information in
> that which is reported by ethtool -S
> 
>       ...
>       eth_red_drops: 0
>       be_on_die_temperature: 52
>       rxq0: rx_bytes: 67532255030
>       ...

Thanks for the comment.  I will use ethtool -S <ethX> option to populate
board temperature.

> 
> rick jones
> 
