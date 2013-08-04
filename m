From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v1 0/4] USB & USBNET: loose SG check and support usbnet
 DMA SG
Date: Sun, 4 Aug 2013 08:28:06 +0800
Message-ID: <CACVXFVOoAX8dR8DfmQwJE=d9vyWD+io_jvfc6KmusQCdowA9wA@mail.gmail.com>
References: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55628 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab3HDA2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 20:28:08 -0400
In-Reply-To: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 3, 2013 at 10:46 AM, Ming Lei <ming.lei@canonical.com> wrote:
> Hi,
>
> This patchset allows drivers to pass sg buffers which size can't be divided
> by max packet size of endpoint if the host controllers(such ax xHCI) support
> this kind of sg buffers.
>
> Previously we added check[1] on the situation and don't allow these sg buffers
> passed to USB HCD, looks the check is too strict to make use of new feature of
> new hardware(xHCI) for some applications(such as network stack) which can't
> provide this kind of sg buffers to usbnet driver, so the patch looses the check
> in case that the host controller supports it.
>
> Patch 3/4 implements DMA SG on usbnet driver, and patch 4/4 uses it on ax88179_178a
> USB3 NIC for supporting TSO, so both CPU utilization and tx throughput can be
> improved with TSO and DMA SG in case of the USB NIC is attached to xHCI controller.
>
> This patchset is against Eric Dumazet's patch(ax88179_178a: avoid copy of tx
> tcp packets), so maybe it is better to merge via net-next tree.

Looks it is a bit complicated, so it can't work via net-next.

- patch 1/4 depends on current usb-next tree
- patch 2/4 depends on patch 1/4
- patch 4/4 depends on both patch 1/4 and Eric's patch

Thanks,
--
Ming Lei
