From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/3] x86_64, sfc: 128-bit memory-mapped I/O
Date: Tue, 21 Aug 2012 18:59:50 -0700
Message-ID: <50343D16.4040901@zytor.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>  <50343810.2000809@zytor.com> <1345599783.2659.82.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37139 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754863Ab2HVCAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 22:00:09 -0400
In-Reply-To: <1345599783.2659.82.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 06:43 PM, Ben Hutchings wrote:
> On Tue, 2012-08-21 at 18:38 -0700, H. Peter Anvin wrote:
>> On 08/21/2012 06:17 PM, Ben Hutchings wrote:
>>> Current Solarflare network controllers have 128-bit memory-mapped
>>> registers which are normally accessed through a series of I/O
>>> operations.  However, it is also possible to access them with a single
>>> MOVAPS instruction on x86_64, and this is measurably faster as it
>>> requires only one PCIe transaction.
>>
>> Also, have you considered doing this with write combining instead?
> 
> We tried it, and it goes horribly wrong.  On some systems, the writes
> are not combined, but they are reordered in a way the hardware doesn't
> support.  See the comment at the top of drivers/net/ethernet/sfc/io.h.
> 

Yes, you have to make sure you properly enforce the necessary ordering
requirements manually (I think you can do that with sfence).

	-hpa
