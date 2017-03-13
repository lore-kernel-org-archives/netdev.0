From: Thierry Du Tre <thierry@dtsystems.be>
Subject: Re: [PATCH v2] VLAN, support ingress/egress priority map flushing
Date: Mon, 13 Mar 2017 21:33:52 +0100
Message-ID: <48d6c820-db6c-8366-9372-a1dfe958cfc1@dtsystems.be>
References: <f07d2296-31e0-30b1-c798-f5f1d87d573a@dtsystems.be>
 <1489418918.28631.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33290 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751826AbdCMUd4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 16:33:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id n11so11782981wma.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 13:33:55 -0700 (PDT)
In-Reply-To: <1489418918.28631.82.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-03-17 16:28, Eric Dumazet wrote:
> On Mon, 2017-03-13 at 15:36 +0100, Thierry Du Tre wrote:
>
>> +void vlan_dev_flush_egress_priority(const struct net_device *dev)
>> +{
>> +	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
>> +	struct vlan_priority_tci_mapping *mp;
>> +	int i;
>> +
>> +	for (i = 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
>> +		while ((mp = vlan->egress_priority_map[i]) != NULL) {
>> +			vlan->egress_priority_map[i] = mp->next;
>> +			kfree(mp);
>> +		}
>> +	}
>> +	vlan->nr_egress_mappings = 0;
>> +}
>
> Are you doing this on a live device ?
>
> Looks you'll need proper RCU support then.
>
> Otherwise, crashes will happen, say in egress_priority_map()
>
> smp_rmb() wont be enough if items can now be destroyed.
Yes, good point about the smp concurrency.
I wrongly assumed there was already some locking mechanism in place to 
protect these structures.

Let me take a look at this and I'll come back with a new proposal.
