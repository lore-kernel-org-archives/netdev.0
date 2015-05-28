From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: include datapath actions with
 sampled-packet upcall to userspace
Date: Wed, 27 May 2015 21:16:19 -0700
Message-ID: <CAEP_g=9BERghUFqsL0B=mraDwuji285nnWGHBsLmDvFz6ZjOJQ@mail.gmail.com>
References: <1432150358-13108-1-git-send-email-neil.mckee@inmon.com>
 <CALnjE+rxMdfZFe5nTGzJSpeH4a1+0Z3ka8Gur1jGmVNBPAcF+w@mail.gmail.com>
 <CAEP_g=8fRDQWfDo0HszXezDzOc4xntKUpJf5ucVrcsZ6M+OSZQ@mail.gmail.com> <CALnjE+r175gt=umf6DCi82HQqiZnj+U7Vg3j+HCBXeFAqN-s3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neil McKee <neil.mckee@inmon.com>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:43193 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750716AbbE1EQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 00:16:40 -0400
Received: by mail-yk0-f173.google.com with SMTP id d142so9238308yke.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 21:16:39 -0700 (PDT)
In-Reply-To: <CALnjE+r175gt=umf6DCi82HQqiZnj+U7Vg3j+HCBXeFAqN-s3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 7:46 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, May 27, 2015 at 2:10 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Fri, May 22, 2015 at 10:53 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>> On Wed, May 20, 2015 at 12:32 PM, Neil McKee <neil.mckee@inmon.com> wrote:
>>>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>>>> index b491c1c..ee5760d 100644
>>>> --- a/net/openvswitch/actions.c
>>>> +++ b/net/openvswitch/actions.c
>>>> @@ -608,7 +608,8 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
>>>>  }
>>>>
>>>>  static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>>>> -                           struct sw_flow_key *key, const struct nlattr *attr)
>>>> +                           struct sw_flow_key *key, const struct nlattr *attr,
>>>> +                           const struct nlattr *actions, int actions_len)
>>>>  {
>>>>         struct ovs_tunnel_info info;
>>>>         struct dp_upcall_info upcall;
>>>> @@ -619,6 +620,8 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>>>>         upcall.userdata = NULL;
>>>>         upcall.portid = 0;
>>>>         upcall.egress_tun_info = NULL;
>>>> +       upcall.actions = actions;
>>>> +       upcall.actions_len = actions_len;
>>>>
>>> Rather than unconditionally passing actions to the upcall, there
>>> should be attribute in ovs_userspace_attr to request the actions list.
>>
>> Why? It seems simpler to just always pass the actions and I'm not sure
>> that this is really performance critical (which is the only reason
>> that comes to mind to not always pass this).
>
> This is only required for sFlow sampling so I do not think we should
> send it on every upcall.

But what is the downside?
