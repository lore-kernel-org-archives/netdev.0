From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] remove net driver ugliness that sparse complains about
Date: Sat, 29 May 2004 11:23:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405291117511.1648@ppc970.osdl.org>
References: <40B8D2F8.6090905@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>,
        Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
        Arjan van de Ven <arjanv@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40B8D2F8.6090905@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 29 May 2004, Jeff Garzik wrote:
> 
> I'm a bit curious why sparse complained about taking the _address_ of 
> pointer

It may not complain any more. Al sent me about 20 different test-cases for
things that sparse did wrong, and I've fixed most of them. As of
yesterday, most sparse warnings really _are_ valid (yeah, I'm sure there
are some broken cases still, but if so, now they are in a clear minority).

Note that that doesn't mean that they are all easy to fix. Some code tends
to re-use the same structure for sometimes holding kernel pointers, and
sometimes holding user pointers.

Since the whole point of sparse is to have _static_ typechecking, such
code will never be sparse-clean, and either we have to ignore it, or we
should split up the use into two different kinds of structures (with the
same members apart from the address space) and explicitly convert between
the two.  I'd obviously prefer that approach, but it might be a fair
amount of work (most of it should be really trivial, though, and I suspect
it would clarify pointer usage a lot to know when a "struct msghdr" points
to user space, and when it points to kernel space. Or whatever - maybe 
that was a bad example).

		Linus
