From: Steve Modica <modica@sgi.com>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 15:09:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EAEDBE9.1060405@sgi.com>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de> <3EAED567.2090006@sgi.com> <20030429195924.GC349@Wotan.suse.de>
Reply-To: netdev@oss.sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030429195924.GC349@Wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Andi Kleen wrote:
>>At issue is really application capture and customer adoption.  There are
>>tons of apps and lots of engineers that know socket operations and 
>>write/writev.  Asking all ISVs to recode for linux would leave them with 
>>two separate APIs to deal with. They would have send/sendto or 
>>write/writev on Solaris, HPUX and whatever else, and linux would have 
>>sendfile.
> 
> 
> aio_write / lio_listio exists on Solaris and HP/UX too.
> 
> (and even Windows; their completion port interfaces are very similar) 

Right.. although some might say that aio_write is used a lot less often 
than write or send.

It's hard to convince thousands of application writers to revisit stuff 
like this.  It's a lot easier to bring the hardware feature in to the 
APIs that people just commonly use.

> 
> 
>>We really want to do this in such a way that it doesn't create a huge 
>>footprint (and we think we can) and we want to make sure we don't impact 
>>systems that can't take advantage of fast TLB updates.
> 
> 
> So how do you avoid the two TLB flush IPIs to all CPUs that have the current mm
> mapped ?
> 
> -Andi

I could speculate about how we might avoid that, or I could speculate 
that even with those operations, it would still be faster, but I'd 
rather just demonstrate it with a patch.

Don't get me wrong, we would certainly drop any notions of this if we 
found that it was slower and I will be glad to post any results. The 
goal is to take advantage of the hardware to make things faster.

Going back to your example above, don't solaris and hpux also do COW for 
write and send? (I don't have their sources)  If so, why would they do 
it if it's slower?

Steve

-- 
Steve Modica
work: 651-683-3224
mobile: 651-261-3201
Manager - Networking Drivers Group
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
