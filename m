From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH/RFC] openvswitch: loosen restriction of output of MPLS to
 tunnel vports
Date: Tue, 16 Feb 2016 14:53:39 -0800
Message-ID: <CAEh+42g5GXduCgr0WCyAKvSO6LeATFuZoWU2aR0sfNDbJqG=6Q@mail.gmail.com>
References: <1455305133-23285-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:48849 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756143AbcBPWx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 17:53:56 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id DFF7D202EC
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 22:53:54 +0000 (UTC)
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1BF4E202BE
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 22:53:54 +0000 (UTC)
Received: by mail-qg0-f43.google.com with SMTP id b67so145747228qgb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 14:53:54 -0800 (PST)
In-Reply-To: <1455305133-23285-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2016 at 11:25 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> If an skb was not MPLS initially then it may be GSO and in that case if it
> became MPLS then GSO can't be performed because both MPLS and tunnels make
> use of the inner_protocol field of struct skbuff in order to allow GSO to
> be performed in the inner packet.
>
> On the other hand if an skb was MPLS initially then it will not be GSO,
> as there is no support for GRO for MPLS. Thus in this case it is safe
> to allow output of MPLS on tunnel vports.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

I don't think that any tunnel implementations expose support for MPLS
offloads as part of their features. In that case, if we have an MPLS
GSO packet (regardless of how it came to be), I think it will be
broken apart in software before encapsulation. At that point, it
should be safe for the tunnel to overwrite any fields MPLS was
previously using for offloading. As a result, I believe we can allow
all combinations of MPLS with tunnels. (Note that historically this
wasn't true, the change is a result of lightweight tunnels.)
