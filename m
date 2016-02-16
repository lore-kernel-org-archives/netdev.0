From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Tue, 16 Feb 2016 08:44:02 -0800
Message-ID: <CALx6S37OgkxTLv6XEjFN4T=W8ZdZV_kx4wtPqtVwMizoUXbpVw@mail.gmail.com>
References: <1455036424-6403-1-git-send-email-david@weave.works>
	<1455036424-6403-3-git-send-email-david@weave.works>
	<CALx6S37sD+MNK+kp9oLnEYHEUkOy_NdQK6bq-aMQP2Mvw9M4Qg@mail.gmail.com>
	<86a8n86bcs.fsf@weave.works>
	<CAEh+42iGHk9zVYPcpSz5w5XPg450p8avuQLbMZZH+B5fZvF9WQ@mail.gmail.com>
	<CALx6S36kvXJUZM8_vEmF8L3bxnRiBh98Rs0wAd-HGBJ9Yyde_Q@mail.gmail.com>
	<CAEh+42gyHEALCjZZGjMWTLQsPgp191c4dfZYFffOL6iV7pwYHw@mail.gmail.com>
	<86vb5o3kd5.fsf@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Wragg <david@weave.works>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37359 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbcBPQoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:44:03 -0500
Received: by mail-ig0-f176.google.com with SMTP id 5so82441933igt.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 08:44:02 -0800 (PST)
In-Reply-To: <86vb5o3kd5.fsf@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 4:33 AM, David Wragg <david@weave.works> wrote:
> Jesse Gross <jesse@kernel.org> writes:
>> On Wed, Feb 10, 2016 at 3:21 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Wed, Feb 10, 2016 at 12:59 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>> On Wed, Feb 10, 2016 at 12:41 PM, David Wragg <david@weave.works> wrote:
>>>>> Tom Herbert <tom@herbertland.com> writes:
>>>>>> The correct thing to do is determine the maximum amount of
>>>>>> encapsulation overhead that can ever be set in a packet and use for
>>>>>> setting the MTU. For instance, when RCO is enable in GUE, the size of
>>>>>> the option is included in tunnel->encap_hlen even though it will not
>>>>>> be used in all packets (via ip_tunnel_change_mtu). If there is no way
>>>>>> to determine a maximum overhead a priori from configuration, then
>>>>>> maximum overhead could be assumed to be maximum possible encapsulation
>>>>>> header size which for Geneve is 132 bytes IIRC.
>>>>>
>>>>> Ok, I'll come up with a patch to address this.
>>>>
>>>> I don't think that this really applies in this situation. The concerns
>>>> here relate to what the MTU is actually set to but this patch affects
>>>> the range of MTUs allowed to be set by the user. I don't see a reason
>>>> to disallow the user from setting a precise value if they know what it
>>>> should be.
>>>>
>>> Right, but if the user sets a bad value and packets are silently
>>> dropped on the floor then that seems like a bad result that could have
>>> easily been prevented.
>>
>> Sure, we might as well prevent the extreme edge cases that can never
>> be valid. In the case of Geneve though, this would be the minimum
>> header size, not the maximum, since it's possible that the user
>> actually knows how big the options are that they want to use.
>>
>> But as I said, the practical impact is low because IP_MAX_MTU is so
>> much larger than the MTU of real devices. There will always be many
>> values that the MTU can be set to that result in dropped packets. This
>> is true of all tunnel types.
>
> I agree with Jesse, and if there was a debate about lifting the MTU
> limit on all tunnel types to IP_MAX_MTU, I'd be for that.
>
> But for the other tunnel types, I followed the precedent of the code
> that was already there, and geneve might as well be consistent.
>
Please implement like in ip_tunnel_change_mtu (or better yet call it),
that is the precedent for tunnels.

Tom


> Patch sent to the lists.
>
> David
