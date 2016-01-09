From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net] openvswitch: compute needed headroom for internal vports
Date: Fri, 8 Jan 2016 16:42:54 -0800
Message-ID: <CAEh+42hN8wL7bbALB8SGCKvum2pzT3R0kXUtMfQPg-XP-QZ7Dg@mail.gmail.com>
References: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
 <CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paolo Abeni <pabeni@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:53641 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753672AbcAIAnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 19:43:11 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 81636201C8
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 00:43:10 +0000 (UTC)
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 49A48201EC
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 00:43:09 +0000 (UTC)
Received: by mail-qg0-f41.google.com with SMTP id o11so365426174qge.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 16:43:09 -0800 (PST)
In-Reply-To: <CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 2:53 PM, pravin shelar <pshelar@ovn.org> wrote:
> On Fri, Jan 8, 2016 at 1:50 PM, Paolo Abeni <pabeni@redhat.com> wrote:
>> Currently the ovs internal vports always use a default needed_headroom.
>> This leads to a skb head copy while xmitting on ovs swith via vport
>> that add some kind of encapsulation (gre, geneve, etc.).
>>
>> This patch add book-keeping for the maximum needed_headroom used by
>> the non internal vports in any dp, updating it on vport creation and
>> deletion.
>>
>> Said value is than used as needed_headroom for internal vports,
>> avoiding the above copy.
>>
> Why is this done only for internal devices? In most common case of
> traffic the packet enters OVS from tap or other netdev type vport
> device.

How would you influence the allocation for non-internal devices?
