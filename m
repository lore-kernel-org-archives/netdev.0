From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump
 via switchdev_port_obj ops.
Date: Wed, 06 May 2015 21:42:23 -0700
Message-ID: <554AED2F.80006@intel.com>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com> <554AA530.7000702@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jamal Hadi Salim <jhs@mojatatu.com>, sfeldma@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8494 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbbEGEmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 00:42:25 -0400
In-Reply-To: <554AA530.7000702@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/6/2015 4:35 PM, Jamal Hadi Salim wrote:
> On 05/06/15 17:54, Sridhar Samudrala wrote:
>> - introduce port fdb obj and generic switchdev_port_fdb_add/del/dump()
>> - use switchdev_port_fdb_add/del/dump in rocker/team/bonding ndo ops.
>> - add support for fdb obj in switchdev_port_obj_add/del/dump()
>> - switch rocker to implement fdb ops via switchdev_ops
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> ---
>
> So i raised this earlier. DaveM also chimed in - but it seems still
> in there.
> i havent been following the discussion and i may have missed
> the agreement to keep the new IDs. Could we not just have used netlink
>  IDs (as opposed to a new SWITCHDEV_OBJ_PORT_FDB id)?

I think you are referring to switch port attributes.  See Scott's 
response here on
using netlink IDs for attributes.
http://thread.gmane.org/gmane.linux.network/357694/focus=357921

This patch is adding 'fdb' as new switch port object.  It is similar to 
other
objects like 'VLAN' and 'FIB' that are added by Scott's patches.

>
>> +int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>> +               struct net_device *dev, const unsigned char *addr,
>> +               u16 vid, u16 nlm_flags)
>> +{
>> +    struct switchdev_obj obj = {
>> +        .id = SWITCHDEV_OBJ_PORT_FDB,
>> +        .fdb = {
>> +            .addr = addr,
>> +            .vid = vid,
>> +        },
>> +    };
>> +
>> +    return switchdev_port_obj_add(dev, &obj);
>> +}
>
> cheers,
> jamal
