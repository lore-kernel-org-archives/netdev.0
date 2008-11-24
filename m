From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Mon, 24 Nov 2008 12:33:49 +0000
Message-ID: <20081124123349.GA16755@ff.dom.local>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081124105345.GB13957@ff.dom.local> <492A9ACB.4050504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:37110 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbYKXMd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 07:33:56 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1027855nfc.21
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 04:33:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <492A9ACB.4050504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 01:15:07PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> (Changelog fixed only)
>>
>> pkt_sched: sch_drr: Fix drr_dequeue() loop
>>
>> If all child qdiscs of sch_drr are non-work-conserving (e.g. sch_tbf)
>> drr_dequeue() will busy-loop waiting for skbs instead of leaving the
>> job for a watchdog. Checking for list_empty() in each loop isn't
>> necessary either, because this can never be true except the first time.
>
> Thanks for the report. I don't like to overcomplicate treatment
> of this broken configuration though, so this patch simply returns
> NULL when the inner qdiscs is non-work-conserving.

Hmm... I don't agree with treating this as broken (IIRC Denys
Fedoryshchenko wrote about some case when he prefers TBF over HTB,
and with DRR this could be an interesting alternative), but of course
you are the author and I respect your decision.

Thanks,
Jarek P.
