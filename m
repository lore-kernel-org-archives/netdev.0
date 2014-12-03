From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2 4/7] fs/proc/task_mmu.c: shift mm_access() from
	m_start() to proc_maps_open()
Date: Wed, 3 Dec 2014 18:34:48 +0100
Message-ID: <20141203173448.GA4003@redhat.com>
References: <20140805194627.GA30693@redhat.com> <20140805194655.GA30728@redhat.com> <20141203141433.GA25683@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	David Howells <dhowells@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Sasha Levin <levinsasha928@gmail.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141203141433.GA25683@node.dhcp.inet.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/03, Kirill A. Shutemov wrote:
>
> On Tue, Aug 05, 2014 at 09:46:55PM +0200, Oleg Nesterov wrote:
> > A simple test-case from Kirill Shutemov
> >
> > 	cat /proc/self/maps >/dev/null
> > 	chmod +x /proc/self/net/packet
> > 	exec /proc/self/net/packet
> >
> > makes lockdep unhappy, cat/exec take seq_file->lock + cred_guard_mutex in
> > the opposite order.
>
> Oleg, I see it again with almost the same test-case:
>
> 	cat /proc/self/stack >/dev/null
> 	chmod +x /proc/self/net/packet
> 	exec /proc/self/net/packet

Yes, there are more lock_trace/mm_access (ab)users. Fortunately, they
are much simpler than proc/pid/maps (which also asked for other cleanups
and fixes).

I'll try to take a look, thanks for reminding.

And I agree with Eric, chmod+x probably makes no sense. Still I think
this code deserves some cleanups regardless. To the point I think that
lock_trace() should probably die.

Thanks!

Oleg.
