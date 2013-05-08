From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Linux driver for Realtek RTL8723AU devices with USB ID 0bda:1724
 such as found in Lenovo IdeaPad Yoga 13
Date: Wed, 08 May 2013 15:17:26 -0500
Message-ID: <518AB2D6.1050909@lwfinger.net>
References: <5159B52D.3050601@lwfinger.net> <5189B939.4010905@zytor.com> <518A7814.1070604@lwfinger.net> <518A7D56.3050502@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Dan Williams <dcbw@redhat.com>,
	'George0505' <george0505@realtek.com>,
	Joon Ro <joonhyoung.ro@gmail.com>,
	Greg KH <gregkh@linux-foundation.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <518A7D56.3050502@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/08/2013 11:29 AM, H. Peter Anvin wrote:
> On 05/08/2013 09:06 AM, Larry Finger wrote:
>> On 05/07/2013 09:32 PM, H. Peter Anvin wrote:
>>>
>>> So I can verify that this driver works against 3.8.11 (not against
>>> current -linus because of a build failure), and yes, there is Bluet=
ooth
>>> in this device.  In fact, it seems to work better than some in-tree
>>> drivers I have seen in the past.
>>>
>>> However, I'm confused as to the above and what it implies for the
>>> purpose of the staging tree.  Wasn't the whole point of the staging=
 tree
>>> to have a working-but-ugly driver upstream and have the work to cle=
an it
>>> up happen in the mainline tree instead of off somewhere.
>>
>> Yes, but even staging has some standards. For example, they frown on
>> inclusion of firmware in a massive data block in a file in the drive=
r -
>> it should be in a separate file the /lib/firmware/ tree. In addition=
,
>> the mainline drivers/net/wireless/ tree is only available to devices
>> that use mac80211 for the software-based MAC layer. That conversion =
is a
>> serious effort that may never be done, thus the 8723au driver may ne=
ver
>> leave staging.
>>
>> What are the details of the build failure on the mainline tree? It
>> builds fine here. One possibility is that your source tree has a
>> leftover copy of include/linux/version.h that contains a stale coded
>> value of the kernel version. I just pushed a Makefile fix that cause=
s
>> the compiler to look in the new location for version.h first. If tha=
t
>> doesn't work, please post the error.
>>
>
> Unlikely, since the kernel source tree is clean.
>
> The error is on os_dep/os_intfs.c:
>
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c: In function =91rtw_proc=
_init_one=92:
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:315:3: error: implicit d=
eclaration
> of function =91create_proc_entry=92 [-Werror=3Dimplicit-function-decl=
aration]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:315:11: warning: assignm=
ent makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:322:3: error: implicit d=
eclaration
> of function =91create_proc_read_entry=92 [-Werror=3Dimplicit-function=
-declaration]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:322:9: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:333:21: warning: assignm=
ent makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:364:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:370:7: error: dereferenc=
ing pointer
> to incomplete type
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:372:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:378:7: error: dereferenc=
ing pointer
> to incomplete type
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:381:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:389:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:397:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:405:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:412:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:419:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:426:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:433:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:440:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:447:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:454:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:461:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:468:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:475:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:482:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:489:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:496:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:505:9: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:512:9: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:522:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:539:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:545:7: error: dereferenc=
ing pointer
> to incomplete type
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:547:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:553:7: error: dereferenc=
ing pointer
> to incomplete type
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:555:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:561:7: error: dereferenc=
ing pointer
> to incomplete type
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:563:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:569:7: error: dereferenc=
ing pointer
> to incomplete type
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:572:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:576:8: warning: assignme=
nt makes
> pointer from integer without a cast [enabled by default]
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:582:7: error: dereferenc=
ing pointer
> to incomplete type

I just pushed a "fix" that will allow the driver to build on kernel 3.1=
0-rc0=20
(aka 3.9-git). This one removes all the procfs stuff. It will be added =
back in=20
/sysfs later.

Larry
