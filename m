From: WeipingPan <panweiping3@gmail.com>
Subject: Re: Bonding problem
Date: Mon, 15 Aug 2011 18:22:45 +0800
Message-ID: <4E48F375.7000504@gmail.com>
References: <CANMAZFWYUqDDp+_9EOOubRcvC90zHO9NR7D_N5D=uTjokpgU6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:34670 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab1HOKVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 06:21:11 -0400
Received: by qwk3 with SMTP id 3so2382962qwk.19
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 03:21:11 -0700 (PDT)
In-Reply-To: <CANMAZFWYUqDDp+_9EOOubRcvC90zHO9NR7D_N5D=uTjokpgU6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2011 05:44 PM, Eduard Sinelnikov wrote:
> Hi all,
>
> Following the thread:
> http://marc.info/?l=3Dlinux-netdev&m=3D131282467512508&w=3D2
>
> I have created the this patch for kernel version:3.0.1, which may fix
> the bonding problem
>
> Patch explanation:
> The patch seting all slaves active prior to switching to round robin =
mode.
> This is done to ensure that every posibly active slave will be used i=
n
> communication.
>
> Also, I noticed that just changing the bond_xmit_round_robin will onl=
y
> partially fix the problem.
> Since slaves with inactive bit will not CATCH any trafic.
>
> I wonder if I should remove the check "bond_is_active_slave(slave))"
> in bond_xmit_round_robin
>
> Please advice.
>              Eduard
>
>
My patch is to restore the backup and inactive flag of slave, too,
and I think it is more generic. :-)

Will send it soon.

thanks
Weiping Pan

> On Mon, Aug 08, 2011 at 10:06:05AM -0700, Jay Vosburgh wrote:
>> Andy Gospodarek<andy@greyhouse.net>  wrote:
>>
>>> On Sun, Aug 07, 2011 at 03:00:30PM +0300, Eduard Sinelnikov wrote:
>>>> Hi,
>>>>
>>>> In the kernel 2.6.39.3 ( /drivers/net/bond/bond_main.c).
>>>> In the function =C2 =E2=80=98bond_xmit_roundrobin=E2=80=99
>>>> The code check if the bond is active via
>>>> =E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
>>>> Which actually checks if the slave is backup or active
>>>> What is the meaning of slave being =C2 backup in round robin mode?
>>>> Correct me if I wrong but in round robin every slave should send a
>>>> packet, regardless of being active or backup.
>>>>
>>>> Thank you,
>>>> =C2  =C2  =C2  =C2  =C2  =C2 Eduard
>>> There probably is not a compelling reason to continue to have it.  =
There
>>> may be a reason historically, but I'm not aware what that might be =
at
>>> this point.  For modes other than active-backup, the value of
>>> slave->link and slave->backup should always contain a value that
>>> indicates the slave is up and available for transmit.
>> If you read Eduard's other posts regarding this, the actual
>> issue is that when changing from another mode into round-robin,
>> occasionally slaves will still be marked as "backup" and won't be us=
ed:
>>
> I did notice that one after I sent this first response.
>
>>> Date: Mon, 8 Aug 2011 11:16:39 +0300
>>> Subject: On line Bonding configuration change fails
>>> From: Eduard Sinelnikov<eduard.sinelnikov@gmail.com>
>>> To: netdev@vger.kernel.org
>>> Sender: netdev-owner@vger.kernel.org
>>>
>>> Hi,
>>>
>>> My configuration is a follows:
>>>
>>> =C2  =C2  =C2  =C2  =C2  =C2  =C2 | eth0 -------------->
>>> Ububntu | eth1 -------------->  =C2  =C2 Swith ------------>  Other=
 computer
>>>
>>> Scenario:
>>> =E2=80=A2 change the bond mode to active/backup
>>> =E2=80=A2 unplug some of the cable
>>> =E2=80=A2 plug-in the unplugged cable
>>> =E2=80=A2 change bond mode to round robin
>>>
>>> I can see that only one eth1 is sending data. When I unplug it the =
ping stops.
>>>
>>> Is it a bug or some mis-configuration?
>>>
>>> In the kernel ( /drivers/net/bond/bond_main.c).
>>> In the function =C2 =E2=80=98bond_xmit_roundrobin
>>> =E2=80=99
>>> The code check if the bond is active via
>>> =E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
>>> Which actually checks if the slave is backup or active
>>> What is the meaning of backup in round robin?
>>> Correct me if I wrong but in round robin every slave should send a
>>> packet, regardless of being active or backup.
>> So from looking at the code, it seems that the actual problem is
>> that when transitioning to round-robin mode, one or more slaves can
>> remain marked as "backup," and in round-robin mode, that won't ever
>> change.  We could probably work around that by removing the "is_acti=
ve"
>> test (essentially declaring that "is_active" is only valid in
>> active-backup mode).  That might produce a few odd messages here and
>> there (when removing a slave or during a link failure, for example).
>>
>>  From inspection, the bond_xmit_xor function likely has this same
>> problem.
>>
> Agreed.
>
>> -J
>>
>> ---
>> -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

