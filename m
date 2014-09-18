From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv5 net-next 3/3] sunvnet: generate ICMP PTMUD messages
 for smaller port MTUs
Date: Thu, 18 Sep 2014 15:23:54 -0400
Message-ID: <541B314A.8090203@oracle.com>
References: <5419F3E5.4050708@oracle.com> <20140917224351.GM26828@oracle.com> <541A1C46.90201@oracle.com>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48476 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbaIRTX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 15:23:57 -0400
In-Reply-To: <541A1C46.90201@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/2014 07:41 PM, David L Stevens wrote:
>
>
> On 09/17/2014 06:43 PM, Sowmini Varadhan wrote:
>> On (09/17/14 16:49), David L Stevens wrote:
>>> +
>>> +			rt = ip_route_output_key(dev_net(dev), &fl4);
>>> +			if (!IS_ERR(rt)) {
>>
>> As I've mentioned before, this layering violation makes me uneasy,
>> so its benefits should be evaluated carefully.  You will typically not be
>> able to find an rt for packets coming here from any application
>> that does not itself use/update the FIB, e.g., uspace based packet-injectors
>> (PF_PACKET-based applications, intel dpdk-based uspace stacks etc.)

>
> A pair of Linux LDOMs can get 8X throughput improvement by raising the MTU to 64K, but
> many packets will be *silently* dropped if they go to any other destination that does
> not support 64K MTU. Those destinations that don't support 64K MTU include any legacy
> Linux running the pre-jumbo code and all Solaris hosts, including the current releases.

by now I am actually quite confused by what the Administrator will see.
If I do "ifconfig -a" or "ip addr", what is the reported mtu of the 
interface?


> Also, I wouldn't call it a layering violation. icmp_send() is the external API for
> triggering ICMP errors, and we are sending them at the point where we know the next-hop MTU.
> It is exactly equivalent to an Ethernet device connected to a switch where the switch
> sends useful layer-3 packets (like IGMP queries). In this case, that useful layer 3 info
> is remote link MTU data; something not available in ordinary Ethernet.

Interesting. So if the Administrator sets up ICMP filters for 
outbound/inbound (at the IP layer), what will be the observed behavior?

--Sowmini
