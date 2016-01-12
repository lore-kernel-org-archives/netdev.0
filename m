From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: compute needed headroom for internal vports
Date: Mon, 11 Jan 2016 16:34:25 -0800
Message-ID: <CAOrHB_DL6DpyoLYZroccPR7mjUuMM-JN6p-=o6XE53Ltb_Cq0w@mail.gmail.com>
References: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
	<CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
	<CAEh+42hN8wL7bbALB8SGCKvum2pzT3R0kXUtMfQPg-XP-QZ7Dg@mail.gmail.com>
	<CAOrHB_Bo2iqp2xGaZpOb2AvriGTTruC_O72hQ7LqKnkbR_CAeA@mail.gmail.com>
	<1452501788.5027.13.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:48352 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbcALAea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 19:34:30 -0500
Received: from mfilter35-d.gandi.net (mfilter35-d.gandi.net [217.70.178.166])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id 80061FB883
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 01:34:28 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter35-d.gandi.net (mfilter35-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 2480G6ZwCWEy for <netdev@vger.kernel.org>;
	Tue, 12 Jan 2016 01:34:26 +0100 (CET)
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id D5B1BFB887
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 01:34:26 +0100 (CET)
Received: by mail-ig0-f180.google.com with SMTP id t15so108544122igr.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 16:34:26 -0800 (PST)
In-Reply-To: <1452501788.5027.13.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 12:43 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Fri, 2016-01-08 at 18:44 -0800, pravin shelar wrote:
>> On Fri, Jan 8, 2016 at 4:42 PM, Jesse Gross <jesse@kernel.org> wrote:
>> > On Fri, Jan 8, 2016 at 2:53 PM, pravin shelar <pshelar@ovn.org> wrote:
>> >> On Fri, Jan 8, 2016 at 1:50 PM, Paolo Abeni <pabeni@redhat.com> wrote:
>> >>> Currently the ovs internal vports always use a default needed_headroom.
>> >>> This leads to a skb head copy while xmitting on ovs swith via vport
>> >>> that add some kind of encapsulation (gre, geneve, etc.).
>> >>>
>> >>> This patch add book-keeping for the maximum needed_headroom used by
>> >>> the non internal vports in any dp, updating it on vport creation and
>> >>> deletion.
>> >>>
>> >>> Said value is than used as needed_headroom for internal vports,
>> >>> avoiding the above copy.
>> >>>
>> >> Why is this done only for internal devices? In most common case of
>> >> traffic the packet enters OVS from tap or other netdev type vport
>> >> device.
>> >
>> > How would you influence the allocation for non-internal devices?
>>
>> Today there is no way of influencing this. But we could add new
>> skb-headroom parameter to netdev for packets that are received on the
>> device. This new parameter could be controlled from master devices
>> like OVS, Bridge, etc. To set this value we need new ndo operation. So
>> that it can work on devices like tap where it would just set this new
>> value and in case of ovs-internal or veth device, it can also update
>> needed_headroom.
>
> My idea was to continue working along this lines.
>
> However I thought to get there incrementally, i.e. handle internal
> vports only first. Can this be ok for you?
>

If the final implementation is going to change alot, then I do not see
much value in this change going in first.
