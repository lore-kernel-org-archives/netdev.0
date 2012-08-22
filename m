From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/3] x86_64, sfc: 128-bit memory-mapped I/O
Date: Tue, 21 Aug 2012 19:31:24 -0700
Message-ID: <5034447C.3020203@zytor.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>   <50343810.2000809@zytor.com>  <1345599783.2659.82.camel@bwh-desktop.uk.solarflarecom.com>  <50343D16.4040901@zytor.com> <1345601423.2659.100.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37365 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755684Ab2HVCbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 22:31:36 -0400
In-Reply-To: <1345601423.2659.100.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 07:10 PM, Ben Hutchings wrote:
>>
>> Yes, you have to make sure you properly enforce the necessary ordering
>> requirements manually (I think you can do that with sfence).
> 
> We did put an sfence after the writes to each register.  But some
> systems only want to combine writes that cover an entire cache line, and
> the writes covering a 128-bit register get broken back up into multiple
> writes at the PCIe level.  And on some systems these are sent in
> decreasing address order, which breaks the rules for writing to
> TX_DESC_UPD.
> 
> To avoid this we'd have to put an sfence in between the writes to a
> register, leaving us back where we started.
> 

You realize the same applies to 128-bit writes, right?  Some cores
and/or systems will break them up.

	-hpa
