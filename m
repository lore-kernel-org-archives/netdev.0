From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: net patches
Date: Tue, 4 Jan 2005 22:48:57 -0800
Message-ID: <20050105064857.GD7961@holomorphy.com>
References: <20050104215913.274e6567.akpm@osdl.org> <20050104223104.2ec87f5b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050104223104.2ec87f5b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Jan 2005 21:59:13 -0800 Andrew Morton <akpm@osdl.org> wrote:
>> I'll unload some accumulated net patches.  I can't say that I've looked at
>> them very closely.

On Tue, Jan 04, 2005 at 10:31:04PM -0800, David S. Miller wrote:
> I'll be quiet for the next few days as I try to discover why
> sparc64 now explodes after the past week of changes.  I'm
> heavily suspecting the 4-level page table stuff.  wli kept
> saying that he was having trouble getting his sparc boxes
> working with the -mm tree over the past month and that's about
> how long the 4-level page table stuff has been in there.
> What's odd is that Andi's original 4-level page table patch
> he gave to me worked just fine on sparc64, but it's been
> changed a lot.

I eventually narrowed this down to something associated with some
unusual core fault handling changes with an unclear relationship to
Andi's 4-level code. Something odd was going on with spec-guided
definitions of pte_read(), pte_write(), et al.

sun4u seemed to do okay with Andi's earlier code in my testing; later
problems seemed to stem from elsewhere (e.g. the ioctl bogon).

$ uname -a
Linux analyticity 2.6.10-rc2-mm2 #8 SMP Sat Dec 18 07:57:42 PST 2004 sparc64 GNU/Linux


-- wli
