From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable() for length check.
Date: Wed, 30 Nov 2016 13:30:25 -0800
Message-ID: <AB6C9BA5-377A-4384-86A1-EF1FB148B0C8@ovn.org>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org> <1480462253-114713-2-git-send-email-jarno@ovn.org> <20161130145159.3cee7ba4@griffin>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pravin Shelar <pshelar@ovn.org>, e@erig.me
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35313 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758313AbcK3Va2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 16:30:28 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so2400358pga.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 13:30:28 -0800 (PST)
In-Reply-To: <20161130145159.3cee7ba4@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Nov 30, 2016, at 5:51 AM, Jiri Benc <jbenc@redhat.com> wrote:
> 
> On Tue, 29 Nov 2016 15:30:52 -0800, Jarno Rajahalme wrote:
>> @@ -504,11 +485,20 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
>> 		goto drop;
>> 	}
>> 
>> -	if (unlikely(packet_length(skb, vport->dev) > mtu &&
>> -		     !skb_is_gso(skb))) {
>> -		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
>> -				     vport->dev->name,
>> -				     packet_length(skb, vport->dev), mtu);
>> +	if (unlikely(!is_skb_forwardable(vport->dev, skb))) {
> 
> How does this work when the vlan tag is accelerated? Then we can be
> over MTU, yet the check will pass.
> 

I’ll check how other call sites use this.

  Jarno

> Jiri
