From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: 2.6.14-rc5 e1000 and page allocation failures.. still
Date: Mon, 24 Oct 2005 15:28:29 -0700
Message-ID: <4807377b0510241528m6afc3501w9d98d66658a38973@mail.gmail.com>
References: <50tDw-1FH-5@gated-at.bofh.it> <435C2D66.6030708@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751118AbVJXW2b@vger.kernel.org>
To: Robert Hancock <hancockr@shaw.ca>
In-Reply-To: <435C2D66.6030708@shaw.ca>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/05, Robert Hancock <hancockr@shaw.ca> wrote:
> John B=E4ckstrand wrote:
> > Im seeing a massive amount of page allocation failures with 2.6.14-=
rc5,
> > and also earlier kernels, see "E1000 - page allocation failure - sa=
ga
[snip]
> It looks like you have enough memory free - the problem is that the
> driver is allocating a block of memory with order 3, which is 8 pages=
=2E
> Quite likely there are not enough contiguous free pages to satisfy th=
at.
>
> That's an awful big buffer size for a packet - I assume you're using
> jumbo frames or something? Ideally the driver and hardware should be
> able to allocate a buffer for those packets in multiple chunks, but I
> have no idea if this is possible.

the latest e1000 driver (6.2.15) from http://sf.net/projects/e1000
fixes this by using multiple descriptors for jumbo frames, therefore
only doing order 0 (single page) page allocations.

let us know how it goes.

BTW why is this so much more common with recent kernels?
