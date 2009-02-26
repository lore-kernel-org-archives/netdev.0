From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] igb: remove skb_orphan calls
Date: Thu, 26 Feb 2009 04:24:06 -0800
Message-ID: <9929d2390902260424i5406e2a1r6c4fbdaaca7d9e6@mail.gmail.com>
References: <20090226104621.10407.46879.stgit@lost.foo-projects.org>
	 <20090226.041412.18567576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, mitch.a.williams@intel.com
To: David Miller <davem@davemloft.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:48171 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbZBZMYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 07:24:09 -0500
Received: by yw-out-2324.google.com with SMTP id 5so393868ywh.1
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 04:24:06 -0800 (PST)
In-Reply-To: <20090226.041412.18567576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 4:14 AM, David Miller <davem@davemloft.net> wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 26 Feb 2009 02:46:23 -0800
>
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> The skb_orphan call in the tx path has been shown to cause issues as seen
>> with the workarounds required for timestamping.
>>
>> In order to avoid this it is easiest just to remove the skb_orphan call as
>> the motivation for including it was purely performance based, and the
>> overall gain from having the call was minimal.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Acked-by: Mitch Williams <mitch.a.williams@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> While I'm happy to apply this, I don't see it as helping the
> timestamping situation.
>
> All someone has to do is enable the new timestamping on loopback to
> trigger the problem, the loopback MUST orphan SKBs before it pushes
> them back into the stack for receive.
>
> Also, Herbert and I have talked about orphaning SKBs even earlier than
> dev_queue_xmit()
>
> This post-send timestamping scheme is not going to work, is poorly
> designed, and needs to be completely rearchitected.
>
> If it isn't fixed soon, I'll have no choice but to completely revert
> all of the timestamping stuff.
> --
>

Adding Emil and Patrick.

While no issues were seen in testing, I will verify with Emil that
loopback testing was done.  Also I will work with Patrick to ensure
that we resolve any issues with lookback and timestamping.

-- 
Cheers,
Jeff
