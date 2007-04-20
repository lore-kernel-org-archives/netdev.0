From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Fri, 20 Apr 2007 11:17:27 +0200
Message-ID: <20070420111727.fc69d671.dada1@cosmosbay.com>
References: <6d6a94c50704200139vb9b24f6y77a6d23544c8f7b9@mail.gmail.com>
	<200704091146.32346.rgetz@blackfin.uclinux.org>
	<1176112223.17975.8.camel@roc-desktop>
	<9561.1176209728@redhat.com>
	<200704101952.05380.rgetz@blackfin.uclinux.org>
	<6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com>
	<2817.1176910411@redhat.com>
	<6d6a94c50704192146k5bbe2aefr31fa5726bf1c1e54@mail.gmail.com>
	<1016.1177055893@redhat.com>
	<2181.1177059532@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Aubrey Li" <aubreylee@gmail.com>,
	"Robin Getz" <rgetz@blackfin.uclinux.org>, uaca@alumni.uv.es,
	bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:51252 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123AbXDTJRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 05:17:31 -0400
In-Reply-To: <2181.1177059532@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Apr 2007 09:58:52 +0100
David Howells <dhowells@redhat.com> wrote:
> 
> Because kmalloc() may be able to get us a smaller chunk of memory.  Actually,
> calling __get_free_pages() might be a better, and then release the excess
> pages.

Interesting, that rings a bell here.

I wonder why we dont use this in alloc_large_system_hash().

(if __get_free_pages(GFP_ATOMIC, order) is used instead of alloc_bootmem() or __vmalloc())

We currently loose 1/4 of space on tcp hash table for example, because sizeof(inet_ehash_bucket) is not a power of 2.

Is it really possible to allocate an order-10 page, then release part of it (say an order-8 subpage) ?

