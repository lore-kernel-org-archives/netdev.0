From: Andy Zhou <azhou@nicira.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 2/2]
 openvswitch: implements the BPF_PROG action in datapath
Date: Thu, 5 Feb 2015 11:34:50 -0800
Message-ID: <CACzMAJJs4vOouGpZGw7OhQ5d=gWF6r+COoM4kaZVjySSw73G0g@mail.gmail.com>
References: <1423090122-19807-1-git-send-email-azhou@nicira.com>
	<1423090122-19807-3-git-send-email-azhou@nicira.com>
	<20150205150733.GG5546@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.com" <dev@openvswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:50876 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751515AbbBETeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:34:50 -0500
Received: by mail-oi0-f51.google.com with SMTP id x69so8115536oia.10
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:34:50 -0800 (PST)
In-Reply-To: <20150205150733.GG5546@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 7:07 AM, Thomas Graf <tgraf@noironetworks.com> wrote:
> On 02/04/15 at 02:48pm, Andy Zhou wrote:
>> BPF_PROG action allows an action to be implemented in eBPF language and
>> downloaded by the userspace at runtime.
>>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>
> Thanks a lot for putting this together Andy and Joe and everybody else
> who was involved. This is much further than what I expected as a first
> step.
>
> One slight open from my side is the avoidance of versioning help of
> helpers. We want to avoid v2, v3, ... helpers if the need should arise
> to extend an existing helper.

I share the concern. Addressing this upfront is a good idea. On the other hand
I am not sure if this is completely avoidable at a reasonable cost.
>
> I think it should be doable with BPF to have the verifier accept if
> a helper is called with less args than expected, to initialize those
> to 0. This would allow for helpers to support additional arguments.
I am not sure it is fundamentally better than V2, v3...   On the other hand,
I agree this looks technically possible.
>
> I think this needs to be documented and expectations should be clear.
> Other than that I'm very very happy with where this is going.
Agreed,

> It seems very doable to also allow for a BPF prog to be registered
> upon flow table miss.
Yes, this is possible, but at the cost of flow set up rate. It may
still be practical
with some optimization, such as caching action lists so we don't
regenerate or download
the same program.
