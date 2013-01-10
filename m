From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v5 02/14] bridge: Add vlan filtering infrastructure
Date: Thu, 10 Jan 2013 14:23:35 -0500
Message-ID: <50EF1537.7030209@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com> <1357751882-8619-3-git-send-email-vyasevic@redhat.com> <20130110103614.23383079@nehalam.linuxnetplumber.net> <50EF0FF7.3080407@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab3AJTXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 14:23:40 -0500
In-Reply-To: <50EF0FF7.3080407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2013 02:01 PM, Vlad Yasevich wrote:
> On 01/10/2013 01:36 PM, Stephen Hemminger wrote:
>> This patch has some minor whitespace and spelling errors:
>>
>> WARNING: line over 80 characters
>> #429: FILE: net/bridge/br_private.h:205:
>> +static inline struct net_bridge_port *vlans_to_port(struct
>> net_port_vlans *vlans)
>>
>> ERROR: trailing whitespace
>> #432: FILE: net/bridge/br_private.h:208:
>> +       $
>>
>> WARNING: please, no spaces at the start of a line
>> #432: FILE: net/bridge/br_private.h:208:
>> +       $
>>
>> +/* Must be protected by RTNL */
>> +static void br_vlan_del(struct net_bridge_vlan *vlan)
>>
>> +    /* Drop the self-ref to trigger descrution. */
>>                                          ^^^^^^^^^^
>>
>
> sorry, will fix.  I thought I ran everything through checkpatch.  I'll
> re-run them.
>
>> Also, the data structure vlan's seems inverted. Why do you keep a hash
>> list
>> of vlan's and then a bitmap of ports. Seems more natural to just put a
>> bitmap
>> on each port that has vlan filtering rather than introducing yet
>> another list
>> to manage.
>>
>
> I originally had it this way.  I found that it wasted space and made
> other things more difficult to do.  For instance, to do egress policy, I
> would have needed another bitmap of vlans... With 4096 vlans, that's
> 512 bytes per port (1024 with policy).
>
> I could probably remove the per-port list.  It would make 2 things a
> little harder:
>    1) detecting if the port has any vlan info at all.
>    2) dumping the vlan information

One other thing would become a little more difficult.  fdb management 
for manually added neighbors.

-vlad

>
> I could pursue this if you think it'll be better.
>
> -vlad
