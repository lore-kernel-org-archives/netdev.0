From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: [net-next 02/11] e1000: Adding e1000_dump function
Date: Tue, 07 Feb 2012 18:38:09 +0100
Message-ID: <1782836.alj52xdzPl@alaris>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com> <1328618038-5008-3-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Tushar Dave <tushar.n.dave@intel.com>, gospo@redhat.com,
	sassmann@redhat.com, jbeulich@suse.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51202 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755258Ab2BGRiL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:38:11 -0500
In-Reply-To: <1328618038-5008-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 07 of February 2012 04:33EN, Jeff Kirsher wrote:
> +		if (netif_msg_pktdata(adapter) && buffer_info->dma !=3D 0)
> +			print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS,
> +					16, 1, phys_to_virt(buffer_info->dma),
> +					buffer_info->length, true);

This might cause problems in Xen environment, we encountered a crash in=
=20
e1000e where phys_to_virt() is used the same way. I'm not familiar with=
=20
the details but this is what Jan Beulich wrote about it:

> And the use of phys_to_virt() here seems wrong - buffer_info->dma,
> afaict, is being obtained via the dma_map_*() APIs, which do NOT
> return a physical address (the fact that what they return is identica=
l
> to the corresponding physical address on native doesn't mean this is
> universally so).
>=20
> bus_to_virt() is what should be used here on Xen (though that isn't
> universally correct either afaik, but there simply is no
> dma_to_virt(); it *is* consistent on x86 and ia64 at least, while
> ppc64 is lacking a definition altogether [I would be very surprised
> though if this use of phys_to_virt() was correct on this arch, given
> that e.g. dma_direct_map_page() uses get_dma_offset() to obtain the
> DMA address]).

                                                         Michal Kube=E8=
ek
