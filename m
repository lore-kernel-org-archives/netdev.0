From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Tue, 19 May 2009 13:00:27 +0300
Message-ID: <4A12833B.4090804@Voltaire.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>	<200905142128.58111.rusty@rustcorp.com.au> <4A0C2500.7090709@Voltaire.com> <4A0D14BF.5010409@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Michael Tokarev <mjt@tls.msk.ru>, Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:28760 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750849AbZESKAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 06:00:37 -0400
In-Reply-To: <4A0D14BF.5010409@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Tokarev wrote:
> A trap which I've seen before. When compiling kvm userspace, ensure your kernel headers installed in
> /usr/include has the latest if_tun.h bits, in particular the TUNSETOFFLOAD
> and IFF_VNET_HDR definitions.

OKay, this seems to be part of my problems... the kvm-85 userspace build uses the header from /usr/include
where <linux/if_tun.h> is dated back to 2001 such that its way different from the 2.6.29.1 one, such that 
TUNSETOFFLOAD and IFF_VNET_HDR are not defined. This means that the qemu code doesn't attempt to issue TUNSETOFFLOAD, and doesn't include <linux/virtio_net.h> which has plus probably more implications. 

> One solution to this is just to copy that file from kernel-2.6.29.  Or
> maybe it's easier to add some -I flags to kvm compile commandline.

This would not be enough since it needs also the virtio_net header and I'm not clear what version, the kernel one  on the one that comes with qemu... Now, all this comes into play only with the qemu provided by kvm releases since the savannah one doesn't have the code that uses TUNSETOFFLOAD, IFF_VNET_HDR etc.

Avi - do you guys have some writeup / guidelines how to make all this work?
 
Or.


