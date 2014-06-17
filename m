From: Dan Aloni <dan@kernelim.com>
Subject: Re: mm/sched/net: BUG when running simple code
Date: Tue, 17 Jun 2014 07:30:14 +0300
Message-ID: <20140617043014.GA18161@gmail.com>
References: <539A6850.4090408@oracle.com>
 <20140613032754.GA20729@gmail.com>
 <539A77A1.60700@oracle.com>
 <20140613041331.GA31688@redhat.com>
 <539FB363.1070302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <539FB363.1070302@oracle.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 16, 2014 at 11:17:55PM -0400, Sasha Levin wrote:
> On 06/13/2014 12:13 AM, Dave Jones wrote:
> > On Fri, Jun 13, 2014 at 12:01:37AM -0400, Sasha Levin wrote:
> > another theory: Trinity can sometimes generate plausible looking module
> > addresses and pass those in structs etc.
> > 
> > I wonder if there's somewhere in that path that isn't checking that the address
> > in the optval it got is actually a userspace address before it tries to write to it.
> 
> It happened again, and this time I've left the kernel addresses in, and it's quite
> interesting:
> 
> [   88.837926] Call Trace:
> [   88.837926]  [<ffffffff9ff6a792>] __sock_create+0x292/0x3c0
> [   88.837926]  [<ffffffff9ff6a610>] ? __sock_create+0x110/0x3c0
> [   88.837926]  [<ffffffff9ff6a920>] sock_create+0x30/0x40
> [   88.837926]  [<ffffffff9ff6ad4c>] SyS_socket+0x2c/0x70
> [   88.837926]  [<ffffffffa0561c30>] ? tracesys+0x7e/0xe6
> [   88.837926]  [<ffffffffa0561c93>] tracesys+0xe1/0xe6
> 
> tracesys() seems to live inside a module space here?

I think it's more likely kASLR. The Documentation/x86/x86_64/mm.txt doc needs updating.

-- 
Dan Aloni

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
