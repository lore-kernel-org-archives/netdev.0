From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ / new Dummy device post.
Date: 19 Apr 2004 22:15:50 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082427350.1034.70.camel@jzny.localdomain>
References: <wazza.87ad18jbdl.fsf@message.id>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: syrius.ml@no-log.org
In-Reply-To: <wazza.87ad18jbdl.fsf@message.id>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-04-19 at 10:22, syrius.ml@no-log.org wrote:

[..]
If you already marked the packets before they hit egress then you
dont need use the ipt mark action. So what you are doing is correct

> $TC qdisc add dev ppp0 root handle 1: prio
> $TC filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 \
>     match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0

Note: this will do for ipv4; if you want ipv6 add a new rule,
in addition to above if you want ipv4, with "protocol ip" replaced by
"protocol ipv6"

> $TC qdisc add dev tun0 root handle 1: prio
> $TC filter add dev tun0 parent 1:0 protocol ip prio 10 u32 \
>     match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0
> 
> $TC qdisc add dev sit1 root handle 1: prio
> $TC filter add dev sit1 parent 1:0 protocol ipv6 prio 10 u32 \
>     match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0

not sure if you need the above but i dont know your setup sufficiently
to be 100%

> but it doesn't work with ipv6 traffic.
> If I try to ping6 somehost, i sometimes get "ping: sendmsg: No buffer
> space available" messages
> anyway, there's nothing going out on sit1.
> 
> Is it the correct way to do it ?

Seems right. Try adding the new ipv6 rule on ppp0 and if you are still
having problems try dumping some stats for the filters and see if they 
are incrementing. eg
tc -s filter show parent 1:0  dev ppp0

also a ifconfig on the dummy0 should show starts going up

cheers,
jamal
