From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: 2.6.24-rc3, 4GB RAM, swiotlb, r8169, out of space
Date: Sun, 25 Nov 2007 00:39:10 +0000
Message-ID: <20071125003910.3e58e3b3@the-village.bc.nu>
References: <200711242344.49958.alistair@devzero.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alistair John Strachan <alistair@devzero.co.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755233AbXKYAmY@vger.kernel.org>
In-Reply-To: <200711242344.49958.alistair@devzero.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> when these messages appear, removing r8169 would appear to be key. Indeed, if 
> there is no significant libata activity, the problem still occurs on the NIC 
> within approximately the same amount of transfer.

You seem to have a leak, which actually isn't suprising

	rtl8169_xmit_frags allocates a set of maps for a fragmented packet

	rtl8169_start_xmit allocates a buffer

When we finish the transit we free the main buffer (always using skb->len
when sometimes its skb->headlne. We don't seem to free the fragment
buffers at all.

Looks like the unmap path for fragmented packets is broken with any kind
of iommu

Alan
