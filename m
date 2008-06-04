From: Bernhard Miklautz <miklautz@inqnet.at>
Subject: Re: Veth problems with bridge
Date: Wed, 04 Jun 2008 15:38:36 +0200
Message-ID: <48469ADC.5070800@inqnet.at>
References: <4845475A.7020207@inqnet.at> <48455240.8070102@trash.net> <4845621E.6080104@inqnet.at> <48456E99.4080803@trash.net>
Reply-To: miklautz@inqnet.at
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <48456E99.4080803@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Patrick McHardy wrote:
>>>> I also tried the whole setup without using veth; the IP directly bound
>>>> to br0, as well as without the bridge at all. No problems with that.
>>>> So there might be some problems with veth?
>>> Does "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables" fix it?
>>
>> On my hardware machine this seems to fix the problem :). But why does
>> bridge-nf-call-iptables influent source nat on an other interface? -
>> Shouldn't the source address always be translated when an output
>> interface is set (iptables -A POSTROUTING -o eth3 -t nat -j MASQUERADE)?
> The bridging code passes packets through IPv4 netfilter and
> connection tracking, so when they hit your MASQUERADE rule,
> the NAT mappings have already been set up.

Remember my setup veth0 and eth1 bridged together to br0, eth3 is the
outgoing interface.

Cases:

1) The ip address set on the bridge and no ip address on veth1 works
   fine regardless whether bridge-nf-call-iptables is set or unset.

2) The ip set on veth1 and no ip on the bridge the
   MASQUERADE rule is only hit when bridge-nf-call-iptables is unset.

If I understood you correctly then the netfilters (nat/postrouting)
would only be applied once in the latter case when
bridge-nf-call-iptables is enabled.

But if veth should behave like a "regular" interface shouldn't the
netfilter rules be applied twice? - First when the packets enter the
bridge on eth0 and leave it on veth0, and secondly when they enter veth1
and and leave it at the final outgoing interface.

Any hint would be appreciated,
best regards,
Bernhard
