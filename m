From: Andi Kleen <ak@muc.de>
Subject: Re: PATCH: kmalloc packet slab
Date: Thu, 30 Dec 2004 19:00:25 +0100
Message-ID: <m1hdm3ll8m.fsf@muc.de>
References: <1104156983.20944.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1104156983.20944.25.camel@localhost.localdomain> (Alan Cox's
 message of "Mon, 27 Dec 2004 14:16:23 +0000")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> The networking world runs in 1514 byte packets pretty much all the time.
> This adds a 1620 byte slab for such objects and is one of the internally
> generated Red Hat patches we use on things like Fedora Core 3. Original:
> Arjan van de Ven.

Doesnt this clash a bit with yours and Arjans no-prisoners-taken 
quest to get rid of order>0 allocations? (4K stacks). 

I implemented this long ago (in 2.1 - bonus points if you still find
the leftover hook), but then gave up on it. I realized that to
use it you would need order>0 allocations. In a single 4K page only 2
1.5K slabs fit, but 2 2K slabs fit as well. And there is already a handy
2K slab that works perfect well.

IMHO it is useless except for architectures with PAGE_SIZE>4K or if 
you fix the VM to handle order>0 allocations really well. If you want
to add it for sparc64/ia64/alpha etc. I would do it with an ifdef
at least. 

-Andi
 
