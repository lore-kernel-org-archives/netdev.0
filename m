From: "Magnos A. Hammes" <magnos@taghos.com.br>
Subject: Re: [PATCH] drivers/net/ethernet/broadcom/bnx2.c
Date: Fri, 02 May 2014 15:27:45 -0300
Message-ID: <5363E3A1.608@taghos.com.br>
References: <5361C29C.5060808@taghos.com.br>	 <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	 <53627814.7090106@taghos.com.br>	 <1398965975.3056.40.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	 <53629752.6030606@taghos.com.br>	 <1398972728.3056.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <1399047974.24523.16.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"desenvolvimento@taghos.com.br" <desenvolvimento@taghos.com.br>
To: Ben Hutchings <ben@decadent.org.uk>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gproxy2-pub.mail.unifiedlayer.com ([69.89.18.3]:60395 "HELO
	gproxy2-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750813AbaEBS2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 14:28:03 -0400
In-Reply-To: <1399047974.24523.16.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02-05-2014 13:26, Ben Hutchings wrote:
> On Thu, 2014-05-01 at 12:32 -0700, Michael Chan wrote:
>> On Thu, 2014-05-01 at 15:49 -0300, Magnos A. Hammes wrote:
>>> Yes, I have some udev rules that run at system boot, but the only
>>> thing
>>> I do is:
>>>
>>> /sbin/udevd --daemon
>>> /sbin/udevadm trigger --type=subsystems --action=add
>>> /sbin/udevadm trigger --type=devices --action=add
>>> /sbin/udevadm settle
>>>
>>> Udev runs normally and returns no errors or warnings and dmesg shows
>>> nothing weird.
>>>
>>> So, you think this may be a problem with my udev rules or a udev bug?
>>>
>>> I'm using udev version 182.
>>
>> udev is involved in locating and loading the firmware file.
>
> It is usually not involved now.  The kernel tries to load files directly
> from /lib/firmware.  Only if that fails and if
> CONFIG_FW_LOADER_USER_HELPER is enabled, then it will issue a uevent
> which udev may respond to (I think that may have been removed from udev
> now).
>
> Ben.

Well, I have CONFIG_FW_LOADER_USER_HELPER enabled and Broadcom 
Corporation NetXtreme II BCM5716 Gigabit Ethernet only works when I 
change the source code of bnx2 to use firmware bnx2-mips-09-6.2.1a.fw 
instead of bnx2-mips-09-6.2.1b.fw, then the kernel loads the right 
firmware file. Or should I write a udev custom rule to load the right 
firmware? (I haven't tried this yet)
It seems to me there is a problem here and changing bnx2 source code 
then recompiling the kernel isn't the best solution.
Udev is properly installed in my initrd and in my Slackware 14.0.

Magnos
>
>> On my
>> system, I have /lib/udev/firmware.sh and a
>> generic /lib/udev/rules.d/50-firmware.rules to make request_firmware()
>> work.  Your system may be different.
>
>
