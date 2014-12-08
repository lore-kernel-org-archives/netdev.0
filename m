From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 18:14:04 +0000
Message-ID: <20141208181401.GD22149@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <CA+55aFz6izpVGxkziynRXg7zbHzteQyPJH1Kg91ZO3fzqn3LaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFz6izpVGxkziynRXg7zbHzteQyPJH1Kg91ZO3fzqn3LaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 10:07:55AM -0800, Linus Torvalds wrote:

> Which is in the vmalloc address space. So somebody used a vmalloc'ed
> address and tried to convert it to a physical address in order to look
> up the page.
> 
> Which is not a valid operation, and the BUG_ON() is definitely proper.
> 
> Now *why* something tried to do a virt_to_page() on a vmalloc'ed
> address, that I leave to others.

iov_iter_get_pages() in ITER_KVEC case, trying to avoid get_user_pages_fast()
and getting it wrong.  FWIW, the reproducer is finit_module(fd, ....)
where fd has been opened with O_DIRECT.  In that case we get kernel_read()
on O_DIRECT and the buffer has just been vmalloc'ed.

What's the sane way to grab struct page * for a vmalloc'ed address?
