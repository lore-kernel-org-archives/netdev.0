From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V4 02/13] bridge: Add vlan filtering infrastructure
Date: Thu, 20 Dec 2012 10:31:14 -0500
Message-ID: <50D32F42.2070904@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com> <1355939304-21804-3-git-send-email-vyasevic@redhat.com> <20121220153913.11a10fd0@pixies.home.jungo.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab2LTPbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 10:31:23 -0500
In-Reply-To: <20121220153913.11a10fd0@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2012 08:39 AM, Shmulik Ladkani wrote:
> Hi Vlad,
>
> On Wed, 19 Dec 2012 12:48:13 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
>> +static void nbp_vlan_flush(struct net_bridge_port *p)
>> +{
>> +	struct net_port_vlan *pve;
>> +	struct net_port_vlan *tmp;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	list_for_each_entry_safe(pve, tmp, &p->vlan_list, list)
>> +		nbp_vlan_delete(p, pve->vid, BRIDGE_FLAGS_SELF);
>
> Why would you want to clear "bridge master port" association from this
> vlan, in the event of NBP destruction?
> The "bridge port" may still be a member of this vlan, doesn't it?
> Seems flags argument should be 0.

This ends up getting fixed later, but you are right.  This should be 0.

>
>> +#define BR_VID_HASH_SIZE (1<<6)
>> +#define br_vlan_hash(vid) ((vid) % (BR_VID_HASH_SIZE - 1))
>
> Did you mean:                       & (BR_VID_HASH_SIZE - 1)

yes.

thanks
-vlad

>
> Regards,
> Shmulik
>
