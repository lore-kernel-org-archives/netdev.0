From: syrius.ml@no-log.org
Subject: Re: IMQ / new Dummy device post.
Date: Wed, 21 Apr 2004 03:43:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wazza.87fzayw1fy.fsf@message.id>
References: <wazza.87ad18jbdl.fsf@message.id>
	<1082427350.1034.70.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082427350.1034.70.camel@jzny.localdomain> (hadi@cyberus.ca's
 message of "19 Apr 2004 22:15:50 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

[...]
>> $TC qdisc add dev ppp0 root handle 1: prio
>> $TC filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 \
>>     match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0
> Note: this will do for ipv4; if you want ipv6 add a new rule,
> in addition to above if you want ipv4, with "protocol ip" replaced by
> "protocol ipv6"

>> $TC qdisc add dev tun0 root handle 1: prio
>> $TC filter add dev tun0 parent 1:0 protocol ip prio 10 u32 \
>>     match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0
>> $TC qdisc add dev sit1 root handle 1: prio
>> $TC filter add dev sit1 parent 1:0 protocol ipv6 prio 10 u32 \
>>     match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0
> not sure if you need the above but i dont know your setup sufficiently
> to be 100%

using 'protocol ipv6' on ppp0 rather than sit1 did the trick.
It's even simplier ! I don't have to create filters for each ipv6 tunnel.

Considering the ipv4 over udp tun0 tunnel, i guess i should prevent
those udp packets to be matched by the filter on ppp0.
I'll optimize it later.

Cheers
                                                        
-- 
