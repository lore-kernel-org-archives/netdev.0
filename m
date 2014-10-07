From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 07 Oct 2014 14:47:52 -0400 (EDT)
Message-ID: <20141007.144752.657165589422333613.davem@davemloft.net>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
	<20141007.130504.1805673129740661479.davem@davemloft.net>
	<CAADnVQJUhEmER7C_OOs0dM_mD8REbYT89SG1dfu2b79AUn9eow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jesse@nicira.com, gerlitz.or@gmail.com,
	alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org, tgraf@suug.ch,
	pshelar@nicira.com, azhou@nicira.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411AbaJGSr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 14:47:58 -0400
In-Reply-To: <CAADnVQJUhEmER7C_OOs0dM_mD8REbYT89SG1dfu2b79AUn9eow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 7 Oct 2014 10:18:25 -0700

> On Tue, Oct 7, 2014 at 10:05 AM, David Miller <davem@davemloft.net> wrote:
>> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>> Date: Tue, 7 Oct 2014 09:50:50 -0700
>>
>>> CHECKSUM_COMPLETE is a burden on software.
>>
>> I totally disagree, it's the most software friendly checksumming
>> offload mechanism possible.  I wish every card did it.
>>
>> CHECKSUM_COMPLETE means that any sub-protocol or tunneling mechanism
>> can be trivially supported without any modifications to hardware, and
>> it therefore makes checksum offloading of new protocols require no
>> hardware changes whatsoever.
> 
> yes, of course. My point is that if HW can parse the packet and validate
> csum it should do that, since it's faster for the stack on top.
> HW can fall back to CHECKSUM_COMPLETE if it fails to parse, for example.
> I think some NICs do exactly that.

I am totally against boolean "yes/no" protocol specific checksum
validation by HW.

It's not faster.  You have to look at the pseudo-header and bring it into
the CPU cache _anyways_, so negating it and 2's complementing it into
the CHECKSUM_COMPLETE value for validation is free.

There is no performance advantage whatsoever to use another checksumming
scheme.
