From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [Patch 12/16 2.5] ixgb: replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 15 Oct 2004 13:10:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E02E6087C@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Christian Borntraeger" <linux-kernel@borntraeger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kmalloc resources are more scarce than vmalloc. In this case, there are
systems where allocation of [rt]xdr->buffer_info fails when the
descriptor ring sizes are set to the maximum allowable value (4096) and
kmalloc is used. Using vmalloc solves this issue.

Ganesh.

-----Original Message-----
From: Christian Borntraeger [mailto:linux-kernel@borntraeger.net] 
Sent: Friday, October 15, 2004 9:47 AM
To: Venkatesan, Ganesh
Cc: jgarzik@pobox.com; netdev
Subject: Re: [Patch 12/16 2.5] ixgb: replace kmalloc with vmalloc to
allocate driver local data structures

Ganesh Venkatesan wrote:
> - rxdr->buffer_info = kmalloc(size, GFP_KERNEL);
[...]
> + rxdr->buffer_info = vmalloc(size);

What is the rationale for this change?

If I recall correctly, Linus opposes the use of vmalloc if there is no
real 
need.

cheers

Christian
