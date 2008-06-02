From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NETFILTER]: fix inconsistent lock state in
	nf_ct_frag6_gather()
Date: Mon, 2 Jun 2008 12:45:01 +0000
Message-ID: <20080602124500.GA4463@ff.dom.local>
References: <20080529120248.GA9702@alice> <20080530105334.GA7378@ff.dom.local> <20080530211315.GA16064@alice> <20080530215314.GA2485@ami.dom.local> <4843CEDE.8030409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Sesterhenn <snakebyte@gmx.de>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:14795 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbYFBMlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 08:41:06 -0400
Received: by fg-out-1718.google.com with SMTP id 19so726628fgg.17
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 05:41:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4843CEDE.8030409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2008 at 12:43:42PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> According to this and another similar lockdep report inet_fragment
>> locks are taken from nf_ct_frag6_gather() with softirqs enabled, but
>> these locks are mainly used in softirq context, so disabling BHs is
>> necessary.
>
> Yes, this can happen on the local output path,
>
>> David & Patrick,
>>
>> It looks like this patch could be applied.
>
> Looks mostly fine, but don't we also have to disable BHs for
> the inet_frag_find() call in nf_ct_frag6_gather()?
>

Probably I miss something, but I think this patch seems to do it:
I can see only one such call in nf_ct_frag6_gather() - with
fq_find()?

BTW, it looks like this lockdep warning points at some other possible
problem: inet_fragment.c uses an SMP "optimization" in
inet_frag_intern(), probably assuming softirq context; so without such
BH blocking around inet_frag_find(), there should be at least
preemption disabled, but I don't know if it's a problem for nf_ct.

Regards,
Jarek P.
