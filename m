From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC 1/3] tc: fix return values of ingress qdisc
Date: Wed, 22 Apr 2015 15:04:03 -0700
Message-ID: <55381AD3.30209@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-2-git-send-email-ast@plumgrid.com> <CAHA+R7NwAdc81bFSoqvXsTpzod0vzT-PV38_Q0N0WTUVGFUY-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33919 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758326AbbDVWEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:04:06 -0400
Received: by pacyx8 with SMTP id yx8so60358pac.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 15:04:05 -0700 (PDT)
In-Reply-To: <CAHA+R7NwAdc81bFSoqvXsTpzod0vzT-PV38_Q0N0WTUVGFUY-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/15 9:59 PM, Cong Wang wrote:
> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> ingress qdisc should return NET_XMIT_* values just like all other qdiscs.
>>
>
> XMIT already means egress...

may be then it should be renamed as well.
from include/linux/netdevice.h:
/* qdisc ->enqueue() return codes. */
#define NET_XMIT_SUCCESS        0x00
...

the point is that qdisc->enqeue() must return NET_XMIT_* values.
ingress qdisc is violating this and therefore should be fixed.

>> Since it's invoked via qdisc_enqueue_root() (which suppose to return
>> only NET_XMIT_* values as well), it was working by accident,
>> since TC_ACT_* values fit within NET_XMIT_MASK.
>>
>
> Why not just add a BUILD_BUG_ON() to capture this?

ingress qdisc returning TC_ACT_* values is an obvious layering
violation. I'm puzzled why it's been this way for so long.
Adding BUILD_BUG_ON is not an option.
