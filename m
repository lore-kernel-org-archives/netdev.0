From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [ovs-dev] [PATCH net-next V8 2/2] openvswitch: 802.1ad: Flow
 handling, actions, and parsing
Date: Tue, 12 May 2015 20:04:46 -0400
Message-ID: <5552951E.4080605@gmail.com>
References: <1430841087-20764-1-git-send-email-thomasfherbert@gmail.com>	<1430841087-20764-3-git-send-email-thomasfherbert@gmail.com> <CALnjE+rQBn3DB0p+NP_hkXDkoTWCB_HKhjo8wM0-VvOSLzO46w@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, ccp@atcnet.net,
	"dev@openvswitch.org" <dev@openvswitch.org>, therbert@redhat.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36270 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964783AbbEMAEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 20:04:49 -0400
Received: by qku63 with SMTP id 63so17841805qku.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 17:04:49 -0700 (PDT)
In-Reply-To: <CALnjE+rQBn3DB0p+NP_hkXDkoTWCB_HKhjo8wM0-VvOSLzO46w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15 2:36 PM, Pravin Shelar wrote:
> On Tue, May 5, 2015 at 8:51 AM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> Add support for 802.1ad including the ability to push and pop double
>> tagged vlans.
>>
>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>> ---
 >....
> checkpatch.pl complains about blank lines.
Pravin, Thanks for your review.
Fixed in V9
>
>>
>>....
> I think we need to invalidate the flow key even when protocol is
> 8021Q. This is because packet is changed from double vlan
> encapsulation to single. In this case vlan 8021Q TCI is mapped to
> different key struct member.
Yes, good catch and thanks. this extra check in the pop and push actions 
wasn't necessary. The original push and pop code in net-next was already 
qinq-ready.
>
>>....
> Same goes here, we need to invalidate flow key here.
See above.
>
>>          else
>>                  key->eth.tci = vlan->vlan_tci;
>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>> index 2dacc7b..0430466 100644
>> --- a/net/openvswitch/flow.c
>> +++ b/net/openvswitch/flow.c
>> @@ -298,21 +298,79 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>>   static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>...
>> +                       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
>> +                                       sizeof(__be16)))
>> +                               return 0;
>> +
> In case of error we need to clear key->eth.tci.
Done. Fixed in V9
>
>
> Move local variable declaration to block where it is actually used.
Done. Fixed in V9
>

> Can you move this vlan key parsing to separate function.
Good idea. In V9, Vlan to key parsing is now consolidated in a separate 
function.
>
>

> I do not see key->eth.ctci mask set according to userspace mask attribute.
> You could use ovs_nested_vlan_from_nlattrs().
Fixed in V9.
>


-- 
Thomas F. Herbert
