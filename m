From: Steve Modica <modica@sgi.com>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 14:41:27 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EAED567.2090006@sgi.com>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030429192041.GC17413@Wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Tue, Apr 29, 2003 at 01:44:15PM -0500, Steve Modica wrote:
> 
>>We are doing some experiementing with Altix systems (Itanium II with
>>NUMA) and we're taking a big hit from __copy_user traffic.  We would
>>like to modify the write, writev, send and sendto interfaces such that
>>we can avoid the __copy_user call by marking pages copy-on-write (COW)
>>and handing them off to be transmitted.  Since this requires TLB 
>>updates, we would only implement this code on platforms that defined 
>>themselves as capable of fast TLB updates.
> 
> 
> A much better way would be to use the POSIX aio interfaces. They support
> zero copy transmit, but don't require COW. Instead they just tell
> the user process when it is safe to touch the buffer again.
> 
> There was already some code to do aio TCP sending, but it didn't
> do zero copy and was not merged for some reason.
> 
> Also you can already do zero copy transmit using sendfile() 
> 
> Linux basically has all the infrastructure you need for this already;
> just the high level interface to the AIO system calls is still missing.
> 
> -Andi

Hi Andi,

We are aware of sendfile() and used it for the purposes of proving that 
zero copy would make a big difference for us.

At issue is really application capture and customer adoption.  There are
tons of apps and lots of engineers that know socket operations and 
write/writev.  Asking all ISVs to recode for linux would leave them with 
two separate APIs to deal with. They would have send/sendto or 
write/writev on Solaris, HPUX and whatever else, and linux would have 
sendfile.

We really want to do this in such a way that it doesn't create a huge 
footprint (and we think we can) and we want to make sure we don't impact 
systems that can't take advantage of fast TLB updates.

Steve


-- 
Steve Modica
work: 651-683-3224
mobile: 651-261-3201
Manager - Networking Drivers Group
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
