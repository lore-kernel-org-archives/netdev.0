From: Bert Lindner <bert-phGP8mJ4Mqk@public.gmane.org>
Subject: Re: 4.5.0 on sun7i-a20-olinuxino-lime2: libphy: PHY
 stmmac-0:ffffffff not found (regression from rc7)
Date: Wed, 16 Mar 2016 16:10:39 +0100
Message-ID: <56E9776F.3070102@a20.net>
References: <56E9413D.9010902@a20.net> <56E945FF.6080005@arm.com>
 <56E94CF4.2060607@arm.com> <56E95B57.1090100@suse.de>
Reply-To: bert-phGP8mJ4Mqk@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>,
 Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
To: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
 Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-sunxi+bncBCTZ7SVI4EMBB5HOUW3QKGQER3NWZ5A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <56E95B57.1090100-l3A5Bk7waGM@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On 2016-03-16 14:10, Andreas F=C3=A4rber wrote:
> Am 16.03.2016 um 13:09 schrieb Robin Murphy:
>> On 16/03/16 11:39, Marc Zyngier wrote:
>>> On 16/03/16 11:19, Bert Lindner wrote:
>>>> Hopefully this is the correct place and way to report this.
>
> The main discussion is on netdev list actually, CC'ed.
>
>>>> For the board sun7i-a20-olinuxino-lime2, there seems to be a problem
>>>> with the eth0 PHY in mainline kernel 4.5.0 that developed since
>>>> 4.5.0-rc7. Ethernet does not work, although eth0 is reported:
>>>>
>>>> root@lime2-079f:~# ip a l eth0
>>>> 2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
>>>> default qlen 1000
>>>>        link/ether 02:c9:05:02:07:9f brd ff:ff:ff:ff:ff:ff
>>>>
>>>>     Difference reported in dmesg:
>>>>
>>>> 4.5.0-rc7:
>>>> [    9.379279] NET: Registered protocol family 10
>>>> [   10.217148]  RX IPC Checksum Offload disabled
>>>> [   10.217195]  No MAC Management Counters available
>>>> [   10.217627] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>>>> [   15.206250] sun7i-dwmac 1c50000.ethernet eth0: Link is Up -
>>>> 1Gbps/Full - flow control off
>>>> [   15.206360] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>>>>
>>>> 4.5.0:
>>>> [    9.767125] NET: Registered protocol family 10
>>>> [   10.357405] libphy: PHY stmmac-0:ffffffff not found
>>>> [   10.362382] eth0: Could not attach to PHY
>>>> [   10.366557] stmmac_open: Cannot attach to PHY (error: -19)
>>>>
>>>> .config is identical for both, also after make oldconfig, apart from
>>>> comment with version number. DTB file is also identical between the tw=
o
>>>> versions.
>>>>
>>>> Kernels are compiled on the board itself. /proc/version string:
>>>> Linux version 4.5.0-rc7 (root@lime2-079f) (gcc version 4.9.1
>>>> (Ubuntu/Linaro 4.9.1-16ubuntu6) ) #1 SMP Mon Mar 7 11:57:25 UTC 2016
>>>> Linux version 4.5.0 (root@lime2-079f) (gcc version 4.9.1 (Ubuntu/Linar=
o
>>>> 4.9.1-16ubuntu6) ) #1 SMP Tue Mar 15 11:39:01 UTC 2016
>>>>
>>>> Please let me know if more info is needed, if I should post complete
>>>> .config, test compile with a particular config or patch, etc. Part of
>>>> .config below.
>>>
>>> Can you please try reverting 88f8b1b ("stmmac: Fix 'eth0: No PHY found'
>>> regression") and report whether or not this changes anything? This seem=
s
>>> to be the only stmac patch between -rc7 and release...
>>
>> Sounds like the same thing as the giant ongoing discussion thread here:
>>
>> http://thread.gmane.org/gmane.linux.drivers.devicetree/159007/focus=3D40=
2830
>
> v4 fixes for 4.5 are here:
>
> https://patchwork.ozlabs.org/patch/598195/ (revert)
> https://patchwork.ozlabs.org/patch/598196/
>
> v2 fixes for linux-next here:
>
> https://patchwork.ozlabs.org/patch/598331/ (revert)
> https://patchwork.ozlabs.org/patch/598332/
>
> Please let Peppe know whether they work for you guys.

Hi guys - I can confirm 4.5.0 minus 88f8b1b works for me:

root@lime2-079f:~# cat /proc/version
Linux version 4.5.0-minus-88f8b1b (root@lime2-079f) (gcc version 4.9.1=20
(Ubuntu/Linaro 4.9.1-16ubuntu6) ) #2 SMP Wed Mar 16 12:50:03 UTC 2016

 From dmesg output:
[    9.731730] NET: Registered protocol family 10
[   10.516893]  RX IPC Checksum Offload disabled
[   10.516948]  No MAC Management Counters available
[   10.517374] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   15.505548] sun7i-dwmac 1c50000.ethernet eth0: Link is Up -=20
1Gbps/Full - flow control off
[   15.505660] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

.. and connected over ethernet.

Thanks, best,

	-bert

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
