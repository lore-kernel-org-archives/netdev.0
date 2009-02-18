From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
Date: Wed, 18 Feb 2009 17:13:03 +1030
Message-ID: <200902181713.03820.rusty@rustcorp.com.au>
References: <20090217222425.GA18801@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	"Jan-Bernd Themann" <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52076 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbZBRGnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 01:43:10 -0500
In-Reply-To: <20090217222425.GA18801@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 18 February 2009 08:54:25 Ira Snyder wrote:
> This adds support to Linux for using virtio between two computers linked by
> a PCI interface. This allows the use of virtio_net to create a familiar,
> fast interface for communication. It should be possible to use other virtio
> devices in the future, but this has not been tested.

Hi Ira,

  It's only first glance, but this looks sane.  Two things on first note:
don't restrict yourself to 32 feature bits (only PCI does this, and they're
going to have to hack when we reach feature 32).

  Secondly:
> +You will notice that the algorithm has no way of handling chains that are
> +not exactly the same on the host and guest system. Without setting any of
> +the fancier virtio_net features, this is the case.

Hmm, I think we can do slightly better than this.

How about prepending a 4 byte length on the host buffers?  Allows host to
specify length (for host->guest), and guest writes it to allow truncated
buffers on guest->host.

That won't allow you to transfer *more* than one buffersize to the host, but
you could use a different method (perhaps the 4 bytes indicates the *total*
length?).

Do 4-byte DMA's suck for some reason?

Cheers,
Rusty.
