From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv11 net-next 2/2] openvswitch: Add support for unique flow IDs.
Date: Wed, 3 Dec 2014 13:02:31 -0800
Message-ID: <CANr6G5zGX8D1ecPhQNXXJb2JCofA0Sz3iQiZ6XJJ31_bmNVP6A@mail.gmail.com>
References: <1417575363-13770-1-git-send-email-joestringer@nicira.com>
 <1417575363-13770-2-git-send-email-joestringer@nicira.com>
 <CANr6G5z-kokWkBs3bb=bXrBmBUhaqHKH1QfeXycFWxSNf00qFw@mail.gmail.com> <CALnjE+qfdFu4Vv3RaUmOtXuvrY+_iCFLNDXhFu2+zDHBJx0L0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALnjE+qfdFu4Vv3RaUmOtXuvrY+_iCFLNDXhFu2+zDHBJx0L0A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3 December 2014 at 11:45, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Dec 3, 2014 at 10:47 AM, Joe Stringer <joestringer@nicira.com> wrote:
>> I forgot to mention that this is the first post based against net-next.
>>
>> On 2 December 2014 at 18:56, Joe Stringer <joestringer@nicira.com> wrote:
>>> <....snip...>
>>> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
>>> index a8b30f3..7f31dbf 100644
>>> --- a/net/openvswitch/flow.h
>>> +++ b/net/openvswitch/flow.h
>>> @@ -197,6 +197,13 @@ struct sw_flow_match {
>>>         struct sw_flow_mask *mask;
>>>  };
>>>
>>> +#define MAX_UFID_LENGTH 256
>>> +
>>> +struct sw_flow_id {
>>> +       u32 ufid_len;
>>> +       u32 ufid[MAX_UFID_LENGTH / 4];
>>> +};
>>> +
>>>  struct sw_flow_actions {
>>>         struct rcu_head rcu;
>>>         u32 actions_len;
>>
>> Pravin, I changed the 'struct sw_flow_id' to the above after feedback
>> from the previous round, but it doesn't seem quite right. Is this what
>> you meant? Given that current ovs-vswitchd userspace only generates
>> 128bit UFIDs, it seems wasteful to be allocating so much for this. Did
>> you have in mind for this to be united with the unmasked_key?
>
> I am fine with 128bits of ufid, we can extend it later if we need it.
> But what do you mean by united unmasked key? Can you define the struct
> here?

What I mean, is that we could define sw_flow_id as:

+struct sw_flow_id {
+       u32 ufid_len;
+       u32 ufid[];
+};

...and just allocate sizeof(struct sw_flow_id) + nla_len(ufid_nlattr),
rather than always allocating a 260B structure.
