From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 01:02:02 -0700
Message-ID: <86802c440808200102n6487ae17ud790991b8ea30d16@mail.gmail.com>
References: <109483.89278.qm@web82104.mail.mud.yahoo.com>
	 <86802c440808192221s3ada5443qc3b9d8e26f252d03@mail.gmail.com>
	 <20080820035130.38426b00.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Witbrodt" <dawitbro@sbcglobal.net>,
	"Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:55988 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbYHTICD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 04:02:03 -0400
Received: by rv-out-0506.google.com with SMTP id k40so351157rvb.1
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 01:02:02 -0700 (PDT)
In-Reply-To: <20080820035130.38426b00.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2008 at 12:51 AM, Bill Fink <billfink@mindspring.com> wrote:
> On Tue, 19 Aug 2008, Yinghai Lu wrote:
>
>> On Tue, Aug 19, 2008 at 9:51 PM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>> > While reading drivers/char/hpet.c and looking at the functions
>> > used there, I discovered request_region(), and realized that it
>> > would be difficult to compare the entire iomem_resource tree to
>> > a dummy tree only containing resources added by insert_resource()
>> > and request_resource().  It might be simpler to have my tiny
>> > e820_reserve_resources() replacement add each resource to 3 trees
>> > -- the real iomem_resource tree, and 2 dummy trees -- which could
>> > then be compared for differences just before the kernel locks up.
>>
>> with reverting patch that change insert_resource to request_resource...
>> 2.6.26 or 2.6.27-rcX still hange somewhere.
>
> This is true if he reverted just the 3def3d6d... commit, but if he
> also reverts the similar, and immediately following, 1e934dda...
> commit, then his 2.6.26 kernel runs fine.

interesting,

David, can you try only comment out

late_initcall(lapic_insert_resource);

YH
