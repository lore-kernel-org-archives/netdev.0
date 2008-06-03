From: Patrick McHardy <kaber@trash.net>
Subject: Re: Veth problems with bridge
Date: Tue, 03 Jun 2008 18:17:29 +0200
Message-ID: <48456E99.4080803@trash.net>
References: <4845475A.7020207@inqnet.at> <48455240.8070102@trash.net> <4845621E.6080104@inqnet.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: miklautz@inqnet.at
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4845621E.6080104@inqnet.at>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernhard Miklautz wrote:
> Hi Patrick,
> 
> Patrick McHardy wrote:
>> Bernhard Miklautz wrote:
>>> [...]
>>> I also tried the whole setup without using veth; the IP directly bound
>>> to br0, as well as without the bridge at all. No problems with that.
>>> So there might be some problems with veth?
>> Does "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables" fix it?
> 
> On my hardware machine this seems to fix the problem :). But why does
> bridge-nf-call-iptables influent source nat on an other interface? -
> Shouldn't the source address always be translated when an output
> interface is set (iptables -A POSTROUTING -o eth3 -t nat -j MASQUERADE)?


The bridging code passes packets through IPv4 netfilter and
connection tracking, so when they hit your MASQUERADE rule,
the NAT mappings have already been set up.

Its a really bad default, but I feel uneasy changing it since
I'm sure some people are relying on it.
