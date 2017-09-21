From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net-next v3] bridge: trigger RTM_NEWLINK when interface is modified by bridge ioctl
Date: Thu, 21 Sep 2017 17:45:17 +0200
Message-ID: <87ingc3vjm.fsf@luffy.cx>
References: <20170920162140.369bb198@xeon-e3>
        <20170921100525.20395-1-vincent@bernat.im>
        <20170921081542.4c266c83@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:32771 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751436AbdIUPpT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 11:45:19 -0400
In-Reply-To: <20170921081542.4c266c83@xeon-e3> (Stephen Hemminger's message of
        "Thu, 21 Sep 2017 08:15:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 21 septembre 2017 08:15 -0700, Stephen Hemminger <stephen@networ=
kplumber.org>=C2=A0:

>> Currently, there is a difference in netlink events received when an
>> interface is modified through bridge ioctl() or through netlink. This
>> patch generates additional events when an interface is added to or
>> removed from a bridge via ioctl().
>>=20
>> When adding then removing an interface from a bridge with netlink, we
>> get:
>>=20
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master b=
ridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master b=
ridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>=20
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master b=
ridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> Deleted 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0=
 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UN=
KNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>=20
>> When using ioctl():
>>=20
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master b=
ridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master b=
ridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>=20
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master b=
ridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state U=
NKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> Deleted 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0=
 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UN=
KNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>=20
>> Without this patch, the last netlink notification is not sent.
>>=20
>> Signed-off-by: Vincent Bernat <vincent@bernat.im>
>
> This makes sense, you should probably add a Fixes: tag to help maintainers
> of long term stable kernels.
>
> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>

I wouldn't know which commit would be fixed since this is not a
regression, just a behavior difference.
--=20
Make sure special cases are truly special.
            - The Elements of Programming Style (Kernighan & Plauger)
