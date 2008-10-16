From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] virtio_net: Improve the recv buffer allocation   scheme
Date: Thu, 16 Oct 2008 20:15:49 +1100
Message-ID: <200810162015.49654.rusty@rustcorp.com.au>
References: <1223494499-18732-1-git-send-email-markmc@redhat.com> <1223574013.13792.23.camel@blaa> <48EE5AE1.5030002@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37876 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440AbYJPJQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 05:16:07 -0400
In-Reply-To: <48EE5AE1.5030002@codemonkey.ws>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 10 October 2008 06:26:25 Anthony Liguori wrote:
> Mark McLoughlin wrote:
> > Also, including virtio_net_hdr in the data buffer would need another
> > feature flag. Rightly or wrongly, KVM's implementation requires
> > virtio_net_hdr to be the first buffer:
> >
> >     if (elem.in_num < 1 || elem.in_sg[0].iov_len != sizeof(*hdr)) {
> >         fprintf(stderr, "virtio-net header not in first element\n");
> >         exit(1);
> >     }
> >
> > i.e. it's part of the ABI ... at least as KVM sees it :-)
>
> This is actually something that's broken in a nasty way.  Having the
> header in the first element is not supposed to be part of the ABI but it
> sort of has to be ATM.
>
> If an older version of QEMU were to use a newer kernel, and the newer
> kernel had a larger header size, then if we just made the header be the
> first X bytes, QEMU has no way of knowing how many bytes that should be.
>   Instead, the guest actually has to allocate the virtio-net header in
> such a way that it only presents the size depending on the features that
> the host supports.  We don't use a simple versioning scheme, so you'd
> have to check for a combination of features advertised by the host but
> that's not good enough because the host may disable certain features.
>
> Perhaps the header size is whatever the longest element that has been
> commonly negotiated?

Yes.  The feature implies the header extension.  Not knowing implies no 
extension is possible.

Rusty.
