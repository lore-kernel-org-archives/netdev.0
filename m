From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Page Allocation Failure with e1000 using jumbo
 frame
Date: Fri, 19 Aug 2005 10:03:08 -0700
Message-ID: <430610CC.50709@us.ibm.com>
References: <1124326404.5546.215.camel@localhost.localdomain> <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ming Zhang <mingz@ele.uri.edu>,
	E1000 <e1000-devel@lists.sourceforge.net>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:

> included netdev...
> 
> 
> On Wed, 17 Aug 2005, Ming Zhang wrote:
> 
>>
>> Hi folks
>>
>> We ran into this problem when running jumbo frame with iscsi over e1000.
>> the MTU1500 is fine while jumbo frame can stably reproduce this error.
>>
>> when meet this error, as reported in iet list, the box still has >600MB
>> ram free. also the slab is not heavily used.
>>
>> any idea on this?
> 
> 
> 
> So, what we do know is that your kernel memory manager is (for whatever 
> unknown reason) having trouble finding contiguous 2^3 pages (32kB) 
> chunks of memory.  This occurs because we need to give our hardware 16kB 
> contiguous (currently, we actually have a patch for this in internal 
> testing) which means that when we do dev_alloc_skb, it allocates 16kB + 
> 16 bytes reserve, plus 2 bytes NET_IP_ALIGN, which takes us into the 
> 32kB slab (power of two roundup)
> 
> I guess we need to approach the memory manager guys and ask them why the 
> current kernels are having so much trouble getting contiguous memory. 
> Also, recently thanks to David Miller's discussions on socket charge, we 
> understand that we're getting hit hard by using such a big buffer.
> 
> Netdev any ideas?

Interesting you should mention this, I just mentioned it
in the context of another thread like 3 seconds ago.

I've talked to Martin Bligh in the past about having the
VM do something sane about these to improve the situation - I'll
go kick, er, ping him again...

The current status is "try not to do that" (large contig allocs).

If anyone has any good ideas, speak up :)

thanks,
Nivedita





-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
