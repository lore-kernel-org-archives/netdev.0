From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 5/5] vxlan: implement GPE in L3 mode
Date: Tue, 8 Mar 2016 14:18:41 -0800
Message-ID: <CAEh+42hoeFJ06k8vOPPRSVNzQTCE1VECJ4pac+BEnAJoAkZgkQ@mail.gmail.com>
References: <cover.1456472746.git.jbenc@redhat.com> <20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
 <CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
 <20160227202159.6507b8b9@griffin> <20160227204428.5f8f25a3@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:39058 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbcCHWS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 17:18:59 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id AEAF92021A
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 22:18:57 +0000 (UTC)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E993A20211
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 22:18:56 +0000 (UTC)
Received: by mail-qk0-f173.google.com with SMTP id s5so12647783qkd.0
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 14:18:56 -0800 (PST)
In-Reply-To: <20160227204428.5f8f25a3@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2016 at 11:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Sat, 27 Feb 2016 20:21:59 +0100, Jiri Benc wrote:
>> You mean returning ETH_P_TEB in skb->protocol? That's not much useful,
>> unfortunately. You won't get such packet processed by the kernel IP
>> stack, rendering the VXLAN-GPE device unusable outside of ovs. It would
>> effectively became a packet sink when used standalone, as it cannot be
>> added to bridge and received packets are not processed by anything -
>> there's no protocol handler for ETH_P_TEB.
>
> Actually, I can do that in the L3 mode (or whatever we'll call it). It
> won't hurt anything and may be useful for openvswitch. Ovs will have to
> special case VXLAN-GPE vport (or perhaps any ARPHRD_NONE port) and set
> skb->protocol to ETH_P_TEB on xmit and dissect correctly the ETH_P_TEB
> packet on rcv.
>
> The L2 mode (or whatever we'll call it) will need to stay, though, for
> non-ovs use cases.

Sorry for the delay in responding but this plan sounds good to me.
