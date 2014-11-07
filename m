From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: kernel panic receiving flooded VXLAN traffic with OVS
Date: Fri, 7 Nov 2014 15:06:46 -0800
Message-ID: <CALnjE+q1t0dbC6-EvxsQvvNafKsk2HNKXBjDrALA9S-gon68PQ@mail.gmail.com>
References: <19014.1415325508@famine>
	<CALnjE+r-s-usJoHq0E74QdorKX2H2cx429xwmsQ2kh+tzp1Y-g@mail.gmail.com>
	<CAEP_g=95s37umz-hLGH0-sB32RcW+t+1dJ=_Eg1jMt4HYG+gEg@mail.gmail.com>
	<CAEP_g=_ToXZB14MY4Y+FaYfNj_GHpaX59n3nzDrkALXHBzK1yw@mail.gmail.com>
	<26235.1415394796@famine>
	<CAEP_g=9gWZYtWGiF-JbVwmesa1n7FXYEJSQKdZi3L_yhPGPkAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev <netdev@vger.kernel.org>,
	"discuss@openvswitch.org" <discuss@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:51501 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751757AbaKGXGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 18:06:53 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so6138183iec.21
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 15:06:46 -0800 (PST)
In-Reply-To: <CAEP_g=9gWZYtWGiF-JbVwmesa1n7FXYEJSQKdZi3L_yhPGPkAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2014 at 2:29 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Nov 7, 2014 at 1:13 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>> Jesse Gross <jesse@nicira.com> wrote:
>>
>>>On Fri, Nov 7, 2014 at 10:34 AM, Jesse Gross <jesse@nicira.com> wrote:
>>>> On Fri, Nov 7, 2014 at 9:40 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>>>> On Thu, Nov 6, 2014 at 5:58 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>> [...]
>>>>>>         I'm not sure if this is an error on the part of the RX / GRO
>>>>>> processing in assembling the GRO skb, or in how OVS calls skb_segment.
>>>>>>
>>>>>
>>>>> I think this is related skb_segment() issue where it is not able to
>>>>> handle this type of skb geometry. We need to fix skb-segmentation. I
>>>>> will investigate it more.
>>>>
>>>> One problem that I see is that vxlan_gro_complete() doesn't add
>>>> SKB_GSO_UDP_TUNNEL to gso_type. This causes us to attempt
>>>> fragmentation as UDP rather than continuing down to do TCP
>>>> segmentation. That probably screws up the skb geometry.
>>>
>>>I sent out a patch to fix this issue. I'm pretty sure that it is the
>>>root cause of the originally reported case but I don't have a good way
>>>to reproduce it so it would be great if you could test it Jay.
>>
>>         I'm having an issue there; when I set up my recreation on
>> current net-next (3.18-rc2) without your new patch, I get the following
>> oops when my ovs script does "ovs-vsctl --if-exists del-br br-ex":
>
> Hmm, that looks like a totally different problem. Pravin - any ideas?

I am not able to reproduce with above command. Jay, Can you send me
steps to reproduce this issue?

Thanks,
Pravin.
