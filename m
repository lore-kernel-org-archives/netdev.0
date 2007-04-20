From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Fri, 20 Apr 2007 21:14:43 +0800
Message-ID: <6d6a94c50704200614n3e258142n4008029171656d23@mail.gmail.com>
References: <200704091146.32346.rgetz@blackfin.uclinux.org>
	 <1176112223.17975.8.camel@roc-desktop> <9561.1176209728@redhat.com>
	 <200704101952.05380.rgetz@blackfin.uclinux.org>
	 <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com>
	 <2817.1176910411@redhat.com>
	 <6d6a94c50704192146k5bbe2aefr31fa5726bf1c1e54@mail.gmail.com>
	 <1016.1177055893@redhat.com>
	 <6d6a94c50704200139vb9b24f6y77a6d23544c8f7b9@mail.gmail.com>
	 <2181.1177059532@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Robin Getz" <rgetz@blackfin.uclinux.org>, uaca@alumni.uv.es,
	bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "David Howells" <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:1988 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993092AbXDTNOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 09:14:45 -0400
Received: by an-out-0708.google.com with SMTP id b33so921599ana
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2007 06:14:43 -0700 (PDT)
In-Reply-To: <2181.1177059532@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/20/07, David Howells <dhowells@redhat.com> wrote:
> Aubrey Li <aubreylee@gmail.com> wrote:
>
> > as checked in packet_set_ring, buffer size must be a multiple of PAGE_SIZE,
> > --------------------packet_set_ring------------------------
> > if (unlikely(req->tp_block_size & (PAGE_SIZE - 1)))
> >
> > So why not use __get_free_pages rather than kmalloc,
>
> Because kmalloc() may be able to get us a smaller chunk of memory.  Actually,
> calling __get_free_pages() might be a better, and then release the excess
> pages.
>

>> so that we have pagetables to count?

>There are no pagetables in NOMMU-mode.

Hmm..., I'm thinking some codes in memory reclaim depend on
NR_FILE_MMAPED like follows
----snip----
if (zone_page_state(zone, NR_FILE_PAGES) -
                        zone_page_state(zone, NR_FILE_MAPPED) >
                        zone->min_unmapped_pages)
----snip----
Since we are enabling packet mmap feature, we should take its mapped
pages into count of NR_FILE_MAPPED.

-Aubrey
