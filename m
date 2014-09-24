From: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Wed, 24 Sep 2014 09:01:05 -0700
Message-ID: <CAHA+R7NfJYzCsZx0E9YVXKVCQbCm_thPSi+80tix8Z9nVA82Ug@mail.gmail.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAHA+R7NnBJ=T3sukzzp-OD2am1nd318XbrXCX84LfSL=nu9ojw@mail.gmail.com>
	<54228D87.3070309@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54228D87.3070309-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 24, 2014 at 2:23 AM, Nicolas Dichtel
<nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:
> Le 23/09/2014 21:22, Cong Wang a =C3=A9crit :
>
>> On Tue, Sep 23, 2014 at 6:20 AM, Nicolas Dichtel
>> <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:
>>>
>>>
>>> Here is a small screenshot to show how it can be used by userland:
>>> $ ip netns add foo
>>> $ ip netns del foo
>>> $ ip netns
>>> $ touch /var/run/netns/init_net
>>> $ mount --bind /proc/1/ns/net /var/run/netns/init_net
>>> $ ip netns add foo
>>> $ ip netns
>>> foo (id: 3)
>>> init_net (id: 1)
>>> $ ip netns exec foo ip netns
>>> foo (id: 3)
>>> init_net (id: 1)
>>> $ ip netns exec foo ip link add ipip1 link-netnsid 1 type ipip remo=
te
>>> 10.16.0.121 local 10.16.0.249
>>> $ ip netns exec foo ip l ls ipip1
>>> 6: ipip1@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN m=
ode
>>> DEFAULT group default
>>>      link/ipip 10.16.0.249 peer 10.16.0.121 link-netnsid 1
>>>
>>> The parameter link-netnsid shows us where the interface sends and
>>> receives
>>> packets (and thus we know where encapsulated addresses are set).
>>>
>>
>> So ipip1 is shown in netns foo but functioning in netns init_net? Ge=
tting
>> the
>> id of init_net in foo depends on your mount namespace, /var/run/netn=
s/ may
>> not visible inside foo, in this case, link-netnsid is meaningless. I=
t
>> is not your
>> fault, network namespace already heavily relies on mount namespace (=
sysfs
>> needs to be remount otherwise you can not create device with the sam=
e
>> name.)
>>
>> On the other hand, what's the problem you are trying to solve? AFAIK=
,
>> the ifindex
>> issue is purely in output, IOW, the device still functions correctly
>> even through
>> its link ifindex is not correct after moving to another namespace. I=
f
>> not, it is bug
>> we need to fix.
>>
> The problem is explained here:
> http://thread.gmane.org/gmane.linux.network/315933/focus=3D316064
> and here:
> http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=3D4=
239
>

Please, summarize the discussion in your changelog, instead of pointing
to a long thread.

And clearly you missed my question above: how do you get netns id
without sharing /var/run/netns/ ?
