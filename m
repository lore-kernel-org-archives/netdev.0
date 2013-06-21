From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: Missing iproute2 support for 802.1ad
Date: Fri, 21 Jun 2013 16:52:41 +0300
Message-ID: <CAKoUArnyR+6bk9UU3GuyteznX-wWVQUfWuaiVuS0YOSKCKKF5w@mail.gmail.com>
References: <20130620231713.4f6a3c1f@xenia.leun.net>
	<CAKoUArm0w70TZvaZSMa1C9vAj+UXsMkza7XTBX0Vq-7B3xrFLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Leun <lkml20130126@newton.leun.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKoUArm0w70TZvaZSMa1C9vAj+UXsMkza7XTBX0Vq-7B3xrFLA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,Michael,

You are right.

It is probably a matter of synchronization between iproute2 git version
and kernel version.

This patch by Patrick McHardy, titled:
"add 802.1ad support", seems to do the job:
http://www.spinics.net/lists/netdev/msg233587.html

But it was not integrated to iproute2 git tree.

But don't be wrong: if you look into this patch, you will see that the
first addition of it was integrated but as a part of a different
patch:
commit 79e9a1db11db494eade7bd6917a34f383c0774e3
Author: Stephen Hemminger <stephen@networkplumber.org>
    titled "Update headers to 3.10".

But you should look at the rest of the patch  of Patrick McHardy ("add
802.1ad support"), it does not appear in the latest git tree of
iproute2.

Please look for example in ip/iplink_vlan.c b/ip/iplink_vlan.c
in the explain() method and compare to the above mentioned patch.


Regards,
Rami Rosen
http://ramirose.wix.com/ramirosen

On Fri, Jun 21, 2013 at 4:49 PM, Rami Rosen <roszenrami@gmail.com> wrote:
> Hello,Michael,
>
> You are right.
>
> It is probably a matter of synchronization between iproute2 git version
> and kernel version.
>
> This patch by Patrick McHardy, titled:
> "add 802.1ad support", seems to do the job:
> http://www.spinics.net/lists/netdev/msg233587.html
>
> But it was not integrated to iproute2 git tree.
>
> But don't be wrong: if you look into this patch, you will see that the first
> addition of it was integrated but as a part of a different patch:
> commit 79e9a1db11db494eade7bd6917a34f383c0774e3
> Author: Stephen Hemminger <stephen@networkplumber.org>
>     titled "Update headers to 3.10".
>
> But you should look at the rest of the patch  of Patrick McHardy ("add
> 802.1ad support"), it does not appear in the latest git tree of iproute2.
>
> Please look for example in ip/iplink_vlan.c b/ip/iplink_vlan.c
> in the explain() method and compare to the above mentioned patch.
>
>
> Regards,
> Rami Rosen
> http://ramirose.wix.com/ramirosen
>
>
>
> On Fri, Jun 21, 2013 at 12:17 AM, Michael Leun
> <lkml20130126@newton.leun.net> wrote:
>>
>>
>>
>> 2013-04-19 12:04:31 GMT kaber@trash.net wrote:
>>
>> > Add support for 802.1ad VLAN devices. This mainly consists of checking
>> > for
>> > ETH_P_8021AD in addition to ETH_P_8021Q in a couple of places and check
>> > offloading capabilities based on the used protocol.
>>
>> > Configuration is done using "ip link":
>>
>> > # ip link add link eth0 eth0.1000 \
>> >       type vlan proto 802.1ad id 1000
>> > # ip link add link eth0.1000 eth0.1000.1000 \
>> >       type vlan proto 802.1q id 1000
>>
>> I fear, that does not work:
>>
>> lara:/home/ml # ip link add link eth0 eth0.1000 type vlan proto 802.1ad id
>> 1000
>> vlan: what is "proto"?
>> Usage: ... vlan id VLANID [ FLAG-LIST ]
>>                           [ ingress-qos-map QOS-MAP ] [ egress-qos-map
>> QOS-MAP ]
>> [...]
>>
>> ip does not seem to know about proto. This does not  have changed in
>> git either.
>>
>> I've seen there was an patch to add this around somewhen in 2011, but
>> it does not seem to have made it.
>>
>> Or did I miss something?
>>
>> --
>> MfG,
>>
>> Michael Leun
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
