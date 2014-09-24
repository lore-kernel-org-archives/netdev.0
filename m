From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/5] rhashtable: Remove gfp_flags from insert and remove functions
Date: Tue, 23 Sep 2014 21:11:31 -0700
Message-ID: <87sijhwtcc.fsf@x220.int.ebiederm.org>
References: <cover.1410782841.git.tgraf@suug.ch>
	<bd3aa4282e89b022620225101ab491e344852f5f.1410782841.git.tgraf@suug.ch>
	<1410784535.7106.164.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140915124937.GB21541@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, john.r.fastabend@intel.com,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140915124937.GB21541@casper.infradead.org> (Thomas Graf's
	message of "Mon, 15 Sep 2014 13:49:37 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> writes:

> On 09/15/14 at 05:35am, Eric Dumazet wrote:
>> On Mon, 2014-09-15 at 14:18 +0200, Thomas Graf wrote:
>> > As the expansion/shrinking is moved to a worker thread, no allocations
>> > will be performed anymore.
>> > 
>> 
>> You meant : no GFP_ATOMIC allocations ?
>> 
>> I would rephrase using something like :
>> 
>> Because hash resizes are potentially time consuming, they'll be
>> performed in process context where GFP_KERNEL allocations are preferred.
>
> I meant to say no allocations in insert/remove anymore but your wording
> is even clearer. I'll update it.
>
>> > -	tbl = kzalloc(size, flags);
>> > +	tbl = kzalloc(size, GFP_KERNEL);
>> 
>> Add __GFP_NOWARN, as you fallback to vzalloc ?
>
> Good point.

It needs to be both __GFP_NOWARN and __GFP_NORETRY.

Otherwise the system will kick in the OOM killer before it falls back to
vzalloc.  Which I can't imagine anyone wanting.

Look at the history of alloc_fdmem in fs/file.c for the real world
reasoning.

Eric
