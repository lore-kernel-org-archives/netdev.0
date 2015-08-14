From: =?UTF-8?Q?S=C3=A9bastien_Bocahu?= <sbu@reportlinker.com>
Subject: Re: Linux kernel commit breaks IPMI on iface downing
Date: Fri, 14 Aug 2015 11:22:22 +0200
Message-ID: <CAJPaPGUsyHwaaTuUGcV5BMsSDcw1T7XQ9GVy5KwsMao3k8u+Kg@mail.gmail.com>
References: <CAJPaPGU2_68J4BZanm+Lw3O+WTiwO3swegh5grP5Bn-XprLOwg@mail.gmail.com>
 <1439515834.7684.24.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: harish.patil@qlogic.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33462 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbbHNJWo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 05:22:44 -0400
Received: by lalv9 with SMTP id v9so40477640lal.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 02:22:42 -0700 (PDT)
In-Reply-To: <1439515834.7684.24.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BNX2 firmware has already been updated to the latest version
available from Dell.

root@debian:~# ethtool -i eth0 | grep firmware
firmware-version: 6.4.5 bc 5.2.3 NCSI 2.0.11

2015-08-14 3:30 GMT+02:00 Michael Chan <mchan@broadcom.com>:
> +netdev and Harish who is the current maintainer of bnx2 at qlogic.
>
> The patch in question effectively just removes the
> bnx2_set_power_state() call during "ip link set down".  If there is
> IPMI, the firmware should know the link needs to stay up when the dri=
ver
> resets the device during bnx2_close().  This should be a very common
> scenario.  Please provide the firmware versions to Harish with ethtoo=
l
> -i.  Perhaps upgrading the firmware can resolve this issue.
>
> On Thu, 2015-08-13 at 15:47 +0200, S=C3=A9bastien Bocahu wrote:
>> Hi,
>>
>> Being unable to install Debian Jessie via IPMI on mainstream Dell R4=
10
>> servers that used to be well supported by Debian Wheezy, I tracked t=
he
>> problem down to a specific commit in the Linux kernel, specifically =
in
>> the bnx2 driver.
>> The issue is that "ip link set eth0 down" takes the Ethernet part of
>> the BMC down (shared NIC for BMC+eth0), cutting off the IPMI session=
=2E
>> The BMC gets back only after power cycling.
>>
>> Hardware: Dell R410 w/ a Broadcom 5716 NIC:
>> Ethernet controller: Broadcom Corporation NetXtreme II BCM5716 Gigab=
it
>> Ethernet (rev 20)  )
>> Part number: BCM95716C1
>> Vendor specific: 6.4.5 (Firmware has been updated to the latest
>> version available by Dell's support website)
>>
>> I built many kernels to track which change caused the issue and it
>> seems that's :
>> 25bfb1dd4ba3b2d9a49ce9d9b0cd7be1840e15ed (bnx2: Add pci shutdown han=
dler.)
>>
>> Before, 'ip link set eth0 down' would just cause 2/3s of packet loss
>> but IPMI would still be working afterwards.
>>
>> I'm available for more informations and/or testing if needed.
>>
>> Thanks !
>>
>>
>>
>
>



--=20
S=C3=A9bastien Bocahu
IT infrastructure manager

4, Rue Montrochet - 69002 - Lyon, France

+33 (0)437651704 - Phone
ReportLinker.com
