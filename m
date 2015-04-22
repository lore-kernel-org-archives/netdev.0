From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 1/3] tc: fix return values of ingress qdisc
Date: Wed, 22 Apr 2015 16:29:48 -0700
Message-ID: <CAHA+R7ODYz4Awh-HuxARktS2vdUa_pEbN_8DZY1Qk4mH7vd=9Q@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-2-git-send-email-ast@plumgrid.com>
	<CAHA+R7NwAdc81bFSoqvXsTpzod0vzT-PV38_Q0N0WTUVGFUY-g@mail.gmail.com>
	<55381AD3.30209@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34019 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758583AbbDVX3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 19:29:49 -0400
Received: by wicmx19 with SMTP id mx19so594839wic.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 16:29:48 -0700 (PDT)
In-Reply-To: <55381AD3.30209@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 3:04 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 4/21/15 9:59 PM, Cong Wang wrote:
>>
>> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com>
>> wrote:
>>>
>>> ingress qdisc should return NET_XMIT_* values just like all other qdiscs.
>>>
>>
>> XMIT already means egress...
>
>
> may be then it should be renamed as well.
> from include/linux/netdevice.h:
> /* qdisc ->enqueue() return codes. */
> #define NET_XMIT_SUCCESS        0x00
> ...
>
> the point is that qdisc->enqeue() must return NET_XMIT_* values.
> ingress qdisc is violating this and therefore should be fixed.

XMIT is non-sense for ingress, you really need to pick another
name for it if TC_ACT_OK isn't okay for you (it is okay for me).


>
>>> Since it's invoked via qdisc_enqueue_root() (which suppose to return
>>> only NET_XMIT_* values as well), it was working by accident,
>>> since TC_ACT_* values fit within NET_XMIT_MASK.
>>>
>>
>> Why not just add a BUILD_BUG_ON() to capture this?
>
>
> ingress qdisc returning TC_ACT_* values is an obvious layering
> violation. I'm puzzled why it's been this way for so long.

Why? Everyone knows ingress is the only qdisc on ingress
and it has no queue and can only accept filters (actions are on filters).

> Adding BUILD_BUG_ON is not an option.
>

It at least tells people we know their value are same, IOW, not a bug.

I don't see the need for the change except a BUILD_BUG_ON().
