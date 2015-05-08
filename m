From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump
 via switchdev_port_obj ops.
Date: Fri, 08 May 2015 13:44:26 -0700
Message-ID: <554D202A.5090207@intel.com>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com> <554AA530.7000702@mojatatu.com> <554AED2F.80006@intel.com> <554CA674.8040905@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jamal Hadi Salim <jhs@mojatatu.com>, sfeldma@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19786 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753101AbbEHUo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2015 16:44:27 -0400
In-Reply-To: <554CA674.8040905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/2015 5:05 AM, Jamal Hadi Salim wrote:
> On 05/07/15 00:42, Samudrala, Sridhar wrote:
>>
>>
>> On 5/6/2015 4:35 PM, Jamal Hadi Salim wrote:
>>> On 05/06/15 17:54, Sridhar Samudrala wrote:
>
>>> So i raised this earlier. DaveM also chimed in - but it seems still
>>> in there.
>>> i havent been following the discussion and i may have missed
>>> the agreement to keep the new IDs. Could we not just have used netlink
>>>  IDs (as opposed to a new SWITCHDEV_OBJ_PORT_FDB id)?
>>
>> I think you are referring to switch port attributes.  See Scott's
>> response here on
>> using netlink IDs for attributes.
>> http://thread.gmane.org/gmane.linux.network/357694/focus=357921
>>
>> This patch is adding 'fdb' as new switch port object.  It is similar to
>> other
>> objects like 'VLAN' and 'FIB' that are added by Scott's patches.
>
> Sorry I missed it - but I am not making sense of Scott's answer.
> The danger of adding these visible APIs is it would be too late
> to take them out once they hit the wild (Dave's famous "the horse
> has left the barn" or look at Jiri's netconf presentation). I hate
> to do this but taking longer to discuss these issues is important.
>
> I will agree that we need some common id to represent the grouping
> of the fdb entries - i will contend using netlink verb-nouns is
> sufficient. Example: RTM_NEWNEIGH is clearly refering to a
> modify or create on an fdb.
> The other issue is how to define optionality.
> So lets start with the fdb object:
> While i would agree they are common, Vlans are optional in an fdb
> entry. The only two items that must be present for an fdb entry are a
> dstmac address and an egress port.
> some low end switches dont do vlans. Therefore there are two IDs
> that must always be present:
>
> The object id for a port is the ifindex.
> The object id for a mac address is NDA_LLADDR
An fdb object is tied to a particular switch port and is associated with a
netdev. So we don't need a port in the fdb object.

>
> The object id for a vlan is NDA_VLAN
> Then there are of course a gazillion other features which may
> be one-of such as the fdb partition id in the netgear switch Ben was
> playing.
>
> I understand the earlier arguement of not needing to have
> multiple parsings of the same thing. But providing parseable
> options means never having to change what the object struct
> looks like. Just provide a scatter list of pointers to the
> different netlink attr-val pairs so it doesnt need to be
> re-parsed.

I think Scott introduced switchdev object abstraction to make the 
switchdev code simpler
and also to enable direct calls to add/delete objects without having to 
create dummy netlink
messages with attributes.
Scott should be able to provide better reasoning behind this abstraction.

>
> Otherwise we are re-inventing things and start to look like
> vendor SDKs.
>
> cheers,
> jamal
>
