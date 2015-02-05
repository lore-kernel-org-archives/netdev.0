From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 2/2]
 openvswitch: implements the BPF_PROG action in datapath
Date: Thu, 5 Feb 2015 16:07:33 +0100
Message-ID: <20150205150733.GG5546@pox.localdomain>
References: <1423090122-19807-1-git-send-email-azhou@nicira.com>
 <1423090122-19807-3-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.com, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:48757 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757790AbbBEPHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 10:07:36 -0500
Received: by mail-wg0-f53.google.com with SMTP id a1so8059976wgh.12
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 07:07:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423090122-19807-3-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 02:48pm, Andy Zhou wrote:
> BPF_PROG action allows an action to be implemented in eBPF language and
> downloaded by the userspace at runtime.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Thanks a lot for putting this together Andy and Joe and everybody else
who was involved. This is much further than what I expected as a first
step.

One slight open from my side is the avoidance of versioning help of
helpers. We want to avoid v2, v3, ... helpers if the need should arise
to extend an existing helper.

I think it should be doable with BPF to have the verifier accept if
a helper is called with less args than expected, to initialize those
to 0. This would allow for helpers to support additional arguments.

I think this needs to be documented and expectations should be clear.
Other than that I'm very very happy with where this is going.

It seems very doable to also allow for a BPF prog to be registered
upon flow table miss.
