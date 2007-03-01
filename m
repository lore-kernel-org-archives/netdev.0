From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Wed, 28 Feb 2007 20:05:10 -0800
Message-ID: <45E650F6.4030404@candelatech.com>
References: <20070228171846.679d8733@dxpl.pdx.osdl.net>	<45E62C29.7010203@candelatech.com> <20070228195611.24cf19ee@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45666 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752030AbXCAEDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 23:03:15 -0500
In-Reply-To: <20070228195611.24cf19ee@deepthought>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 28 Feb 2007 17:28:09 -0800
> Ben Greear <greearb@candelatech.com> wrote:
>
>   
>> Stephen Hemminger wrote:
>>     
>>> I was measuring bridging/routing performance and noticed this.
>>>
>>> The current code runs the "all packet" type handlers before calling
>>> the bridge hook.  If an application (like some DHCP clients) is
>>> using AF_PACKET, this means that each received packet gets run
>>> through the Berkeley Packet Filter code in sk_run_filter (slow).
>>>
>>> By moving the bridging hook to run first, the packets flowing
>>> through the bridge get filtered out there. This results in a 14%
>>> improvement in performance, but it does mean that some snooping
>>> applications would miss packets if being used on a bridge.  The
>>> correct way to see all packets on a bridge is to set the bridge
>>> pseudo-device to promiscuous mode.
>>>       
>> Seems it would be better to fix these clients to be more selective as
>> to where they bind.
>>     
>
> The problem is any use of BPF is a lose, if it has to be done to all
> traffic.
>   
Right, but couldn't you have the dhcp client bind to eth0, eth7, and br0 
(ie, skipping the eth1-6 that comprise the bridge group?)

The only difficulty I see is having the client know when new devices 
come and go, but there are probably
ways to know that without keeping a whole lot of state or probing the 
/proc/net/dev (like my own bloated app does :))

I envision the client args to be something like --skip-devices "eth1 
eth2 eth3 ..."

I know you can bind raw packet sockets to individual devices, though I 
don't know much about BPF, so it's
possible I'm wrong...

>> This breaks the case where you want to see packets on a particular
>> interface, not just the entire bridge, right?
>>     
>
> It might be possible to use promisc counter to handle this.
>   
Not really, it's perfectly valid to sniff a port in non-promiscuous mode...

Ben

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


