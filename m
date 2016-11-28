From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 2/2] openvswitch: Fix skb->protocol for vlan frames.
Date: Mon, 28 Nov 2016 14:58:33 -0800
Message-ID: <D9AE51E6-A695-4B66-8285-56635E08B225@ovn.org>
References: <1479874174-75329-1-git-send-email-jarno@ovn.org> <1479874174-75329-2-git-send-email-jarno@ovn.org> <20161124171046.7eb0e287@griffin> <76814927-D373-4C3A-BC85-5771304235A7@ovn.org> <20161128234246.1a886246@griffin>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33039 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754980AbcK1W6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 17:58:36 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so14339180pgd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 14:58:36 -0800 (PST)
In-Reply-To: <20161128234246.1a886246@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Nov 28, 2016, at 2:42 PM, Jiri Benc <jbenc@redhat.com> wrote:
> 
> On Mon, 28 Nov 2016 14:29:39 -0800, Jarno Rajahalme wrote:
>> I’m not sure what you suggest here. Obviously the kernel ABI can not
>> be changed as existing userspace code expects upcalled packets to be
>> non-accelerated. Also, if userspace pushes vlan headers, the packet
>> will actually have them.
> 
> The user space API needs to be preserved, of course. I'm talking about
> what happens internally in the kernel.
> 
> See this patchset: https://www.spinics.net/lists/netdev/msg398827.html
> 

I did not try to apply this series yet, but given the recent L3 changes maybe it needs a rebase?

>> Would this incremental fix this:
>> 
>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>> index 9be9fda..37f1bb9 100644
>> --- a/net/openvswitch/flow.c
>> +++ b/net/openvswitch/flow.c
>> @@ -354,6 +354,8 @@ static int parse_vlan(struct sk_buff *skb, struct
>> sw_flow_key *key) res = parse_vlan_tag(skb, &key->eth.vlan);
>> 		if (res <= 0)
>> 			return res;
>> +		if (skb->protocol == htons(ETH_P_TEB))
>> +			skb->protocol = key->eth.vlan.tpid;
>> 	}
>> 
>> 	/* Parse inner vlan tag. */
> 
> I'll look at this tomorrow. But it seems we're adding more and more
> hacks instead of cleaning up the vlan handling.
> 

Right, I just noticed that the incremental only handles the VLAN case.

I’ll post a v2 later today with a proper fix that solves the immediate issue. IMO this should be fixed independently of the VLAN handling series for which I have no informed opinion yet.

  Jarno

> Jiri
