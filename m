From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net] openvswitch: compute needed headroom for internal vports
Date: Tue, 12 Jan 2016 17:08:54 -0800
Message-ID: <CAEh+42hvvNG7LRZtL0HjPFny7p2Cu_Bkv4k1aYQxXAWZST4yQQ@mail.gmail.com>
References: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
 <CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
 <CAEh+42hN8wL7bbALB8SGCKvum2pzT3R0kXUtMfQPg-XP-QZ7Dg@mail.gmail.com>
 <CAOrHB_Bo2iqp2xGaZpOb2AvriGTTruC_O72hQ7LqKnkbR_CAeA@mail.gmail.com>
 <1452501788.5027.13.camel@redhat.com> <CAOrHB_DL6DpyoLYZroccPR7mjUuMM-JN6p-=o6XE53Ltb_Cq0w@mail.gmail.com>
 <CAEh+42hr8JneX5bufHNqbVFfnCXkU1iz7n0Pc4UQfm==rKF9Dw@mail.gmail.com> <CAOrHB_C=GxDbZBdKCo0j2z-dNTKRQ6GcpWYr6qGxuF_SxughJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paolo Abeni <pabeni@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:38728 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbcAMBJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 20:09:12 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id DEB7A2042C
	for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 01:09:10 +0000 (UTC)
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0FC2E2041B
	for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 01:09:10 +0000 (UTC)
Received: by mail-qg0-f45.google.com with SMTP id o11so443598228qge.2
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 17:09:10 -0800 (PST)
In-Reply-To: <CAOrHB_C=GxDbZBdKCo0j2z-dNTKRQ6GcpWYr6qGxuF_SxughJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 12:44 PM, pravin shelar <pshelar@ovn.org> wrote:
> On Tue, Jan 12, 2016 at 11:20 AM, Jesse Gross <jesse@kernel.org> wrote:
>> On Mon, Jan 11, 2016 at 4:34 PM, pravin shelar <pshelar@ovn.org> wrote:
>>> On Mon, Jan 11, 2016 at 12:43 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>>> On Fri, 2016-01-08 at 18:44 -0800, pravin shelar wrote:
>>>>> On Fri, Jan 8, 2016 at 4:42 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>>> > On Fri, Jan 8, 2016 at 2:53 PM, pravin shelar <pshelar@ovn.org> wrote:
>>>>> >> On Fri, Jan 8, 2016 at 1:50 PM, Paolo Abeni <pabeni@redhat.com> wrote:
>>>>> >>> Currently the ovs internal vports always use a default needed_headroom.
>>>>> >>> This leads to a skb head copy while xmitting on ovs swith via vport
>>>>> >>> that add some kind of encapsulation (gre, geneve, etc.).
>>>>> >>>
>>>>> >>> This patch add book-keeping for the maximum needed_headroom used by
>>>>> >>> the non internal vports in any dp, updating it on vport creation and
>>>>> >>> deletion.
>>>>> >>>
>>>>> >>> Said value is than used as needed_headroom for internal vports,
>>>>> >>> avoiding the above copy.
>>>>> >>>
>>>>> >> Why is this done only for internal devices? In most common case of
>>>>> >> traffic the packet enters OVS from tap or other netdev type vport
>>>>> >> device.
>>>>> >
>>>>> > How would you influence the allocation for non-internal devices?
>>>>>
>>>>> Today there is no way of influencing this. But we could add new
>>>>> skb-headroom parameter to netdev for packets that are received on the
>>>>> device. This new parameter could be controlled from master devices
>>>>> like OVS, Bridge, etc. To set this value we need new ndo operation. So
>>>>> that it can work on devices like tap where it would just set this new
>>>>> value and in case of ovs-internal or veth device, it can also update
>>>>> needed_headroom.
>>>>
>>>> My idea was to continue working along this lines.
>>>>
>>>> However I thought to get there incrementally, i.e. handle internal
>>>> vports only first. Can this be ok for you?
>>>>
>>>
>>> If the final implementation is going to change alot, then I do not see
>>> much value in this change going in first.
>>
>> Even if the code will change in the future, it seems like an
>> incremental improvement that will help in some cases so I don't see
>> much reason to not do this part now.
>
> I am not sure which cases it help. Can you tell me use cases for
> internal port in production?

Any traffic coming from the hypervisor itself (as well as tunnels
although unless you are doing double encapsulation then this patch
doesn't matter in that case).

Since we're in the merge window now, maybe it makes sense to just go
for the full version in the next cycle in any case.
