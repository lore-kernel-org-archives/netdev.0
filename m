From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] vhost-net: fall back to vmalloc if high-order allocation fails
Date: Thu, 24 Jan 2013 10:37:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B711F@saturn3.aculab.com>
References: <87k3r31vbc.fsf@silenus.orebokech.com> <AE90C24D6B3A694183C094C60CF0A2F6026B711E@saturn3.aculab.com> <20130124100600.GB8710@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Romain Francoise" <romain@orebokech.com>, <kvm@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20130124100600.GB8710@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I think this means that kmalloc() is likely to be faster
> > (if it doesn't have to sleep), but that vmalloc() is
> > allocating from a much larger resource.
> >
> > This make me that that large allocations that are not
> > temporary should probably be allocated with vmalloc().
> 
> vmalloc has some issues for example afaik it's not backed by
> a huge page so  I think its use puts more stress on the TLB cache.

Thinks further ...
64bit systems are likely to have enough kernel VA to be able
to map all of physical memory into contiguous VA.

I don't know if Linux does that, but I know code to map it was added
to NetBSD amd64 in order to speed up kernel accesses to 'random'
pages - it might have been partially backed out due to bugs!

If physical memory is mapped like that then kmalloc() requests
can any of physical memory and be unlikely to fail - since user
pages can be moved in order to generate contiguous free blocks.

Doesn't help with 32bit systems - they had to stop mapping all
of physical memory into kernel space a long time ago.

	David
