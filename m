From: "Roland" <devzero@web.de>
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free
Date: Fri, 2 May 2008 14:38:36 +0200
Message-ID: <008f01c8ac51$83dbd5d0$6400a8c0@bui.materna.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Jonathan Naylor" <g4klx@g4klx.demon.co.uk>
To: "\"Andrew Morton\"" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:39592 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757724AbYEBMjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 08:39:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > i`m also seeing this one, but with pcnet32 - "modprobe -r pcnet32" 
>> > never
>> > returns and
>> >
>> > "unregister_netdevice: waiting for eth0 to become free. Usage count = 
>> > 1"
>> >
>> > being printed over and over again
>> >
>> > lsmod |grep pcnet32 shows
>> >
>> > pcnet32            35828    0
>> > mii                      9344    1    pcnet32
>> >
>> > i see stale ssh connection on port 22 and sshd for that session remains
>> > unkillable process.
>> >
>>
>> here a bug

it seems it`s lapbether driver

reproduce:

on system with pcnet32 (vmware) do

modprobe pcnet32
modprobe lapbether
modprobe -r lapbether
modprobe -r pcnet32 -> hang -> unregister_netdevice: waiting for eth0 to 
become free

didn`t try with other nic`s, but i assume it`s independent from pcnet32

MODULE_AUTHOR("Jonathan Naylor <g4klx@g4klx.demon.co.uk>");
MODULE_DESCRIPTION("The unofficial LAPB over Ethernet driver");
MODULE_LICENSE("GPL");

ok, experimental one, so not a real problem, but CC`ing  the Author.

regards
roland



----- Original Message ----- 
From: "Roland" <devzero@web.de>
To: ""Soeren Sonnenburg"" <kernel@nn7.de>
Cc: <linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>; ""Andrew 
Morton"" <akpm@linux-foundation.org>
Sent: Friday, May 02, 2008 11:31 AM
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free


> >I am not exactly sure which kernel version Roland (?) is/was using but
>>from what I can tell this bug is fixed since 2.6.24 (at least). Well I
>>didn't see it with madwifi nor with the tun devices anymore on any of
>>the 24.X or 25rc's/25 ...
>
> pardon,   2.6.25-git17 in vmware
>
>
>>; <netdev@vger.kernel.org>;
> List:       linux-kernel
> Subject:    Re: 24rc8: unregister_netdevice: waiting for ... to become 
> free.
> From:       Soeren Sonnenburg <kernel () nn7 ! de>
> Date:       2008-05-02 6:15:43
> Message-ID: 1209708943.23075.52.camel () localhost
> [Download message RAW]
>
> On Thu, 2008-05-01 at 22:59 -0700, Andrew Morton wrote:
>> On Fri, 2 May 2008 03:26:28 +0200 "Roland" <devzero@web.de> wrote:
>>
>> > i`m also seeing this one, but with pcnet32 - "modprobe -r pcnet32" 
>> > never
>> > returns and
>> >
>> > "unregister_netdevice: waiting for eth0 to become free. Usage count = 
>> > 1"
>> >
>> > being printed over and over again
>> >
>> > lsmod |grep pcnet32 shows
>> >
>> > pcnet32            35828    0
>> > mii                      9344    1    pcnet32
>> >
>> > i see stale ssh connection on port 22 and sshd for that session remains
>> > unkillable process.
>> >
>>
>> here a bug
>>
>> >
>> >
>> > List:       linux-kernel
>> > Subject:    Re: 24rc8: unregister_netdevice: waiting for ... to become 
>> > free.
>> > From:       Soeren Sonnenburg <kernel () nn7 ! de>
>> > Date:       2008-01-29 8:59:10
>> > Message-ID: 1201597150.4973.10.camel () localhost
>> > [Download message RAW]
>> >
>> > On Tue, 2008-01-22 at 22:44 -0800, David Miller wrote:
>> > > From: Soeren Sonnenburg <kernel@nn7.de>
>> > > Date: Wed, 23 Jan 2008 07:42:21 +0100
>> > >
>> > > > Dear all,
>> > > >
>> > > > since some 2.6.24rc version I suddenly experience such messages on
>> > > > console when trying to shutdown a vpn connection:
>> > > >
>> > > > unregister_netdevice: waiting for tun0 to become free. Usage count 
>> > > > = 1
>> > > >
>> > > > or when removing an usb wlan dongle (although it was ifconfig wlan0
>> > > > down'd before)
>> > >
>> > > Current GIT already has a fix for this, attached below:
>> >
>> > hmmhhh, I am still seeing this problem on 2.6.24 with at least with the
>> > madwifi driver...
>> >
>> > Soeren
>>
>> there a bug.
>>
>>
>> Let's cc netdev@vger.kernel.org - linux-net is dead, afaik.
>>
>> Thanks for reporting all these bugs but please do take much mure care 
>> over
>> the cc's.  Be sure to cc every party who was cc'ed on the email to which
>> you're replying.  I restored Soeren.
>
> I am not exactly sure which kernel version Roland (?) is/was using but
> from what I can tell this bug is fixed since 2.6.24 (at least). Well I
> didn't see it with madwifi nor with the tun devices anymore on any of
> the 24.X or 25rc's/25 ...
>
> Soeren
> 

