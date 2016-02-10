From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Wed, 10 Feb 2016 15:21:01 +0100
Message-ID: <CALx6S36kvXJUZM8_vEmF8L3bxnRiBh98Rs0wAd-HGBJ9Yyde_Q@mail.gmail.com>
References: <1455036424-6403-1-git-send-email-david@weave.works>
	<1455036424-6403-3-git-send-email-david@weave.works>
	<CALx6S37sD+MNK+kp9oLnEYHEUkOy_NdQK6bq-aMQP2Mvw9M4Qg@mail.gmail.com>
	<86a8n86bcs.fsf@weave.works>
	<CAEh+42iGHk9zVYPcpSz5w5XPg450p8avuQLbMZZH+B5fZvF9WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Wragg <david@weave.works>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:33197 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbcBJOVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 09:21:01 -0500
Received: by mail-ig0-f194.google.com with SMTP id hb3so1707399igb.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 06:21:01 -0800 (PST)
In-Reply-To: <CAEh+42iGHk9zVYPcpSz5w5XPg450p8avuQLbMZZH+B5fZvF9WQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2016 at 12:59 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Wed, Feb 10, 2016 at 12:41 PM, David Wragg <david@weave.works> wrote:
>> Tom Herbert <tom@herbertland.com> writes:
>>> The correct thing to do is determine the maximum amount of
>>> encapsulation overhead that can ever be set in a packet and use for
>>> setting the MTU. For instance, when RCO is enable in GUE, the size of
>>> the option is included in tunnel->encap_hlen even though it will not
>>> be used in all packets (via ip_tunnel_change_mtu). If there is no way
>>> to determine a maximum overhead a priori from configuration, then
>>> maximum overhead could be assumed to be maximum possible encapsulation
>>> header size which for Geneve is 132 bytes IIRC.
>>
>> Ok, I'll come up with a patch to address this.
>
> I don't think that this really applies in this situation. The concerns
> here relate to what the MTU is actually set to but this patch affects
> the range of MTUs allowed to be set by the user. I don't see a reason
> to disallow the user from setting a precise value if they know what it
> should be.
>
Right, but if the user sets a bad value and packets are silently
dropped on the floor then that seems like a bad result that could have
easily been prevented.

> In any case, I don't think it is likely to have much impact. By
> default with tunnels the output device is not fixed and therefore the
> base MTU that is used is IP_MAX_MTU. Subtracting some tunnel overhead
> amount from this is still likely quite a bit higher than any physical
> MTU.
>
> If you really want, I would subtract the base Geneve header size from
> IP_MAX_MTU to get the true max but it's probably not a big deal in any
> case.
