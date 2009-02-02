From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v3 3/4] virtio_net: Add a MAC filter table
Date: Mon, 2 Feb 2009 20:27:14 +1030
Message-ID: <200902022027.14581.rusty@rustcorp.com.au>
References: <20090201200504.8183.58421.stgit@debian.lart> <20090201200520.8183.3168.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090201200520.8183.3168.stgit@debian.lart>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 02 February 2009 06:35:20 Alex Williamson wrote:
> + * In addition to the class/cmd header, the TABLE_SET command requires
> + * two out scatterlists.  Each contains a 4 byte count of entries followed
> + * by a concatenated byte stream of the ETH_ALEN MAC addresses.  The
> + * first sg list contains unicast addresses, the second is for multicast.
> + * This functionality is present if the VIRTIO_NET_F_CTRL_RX feature
> + * is available.
> + */
> +struct virtio_net_ctrl_mac {
> +	__u32 entries;
> +	__u8 macs[];
> +} __attribute__((packed));

Hmm, can we make this more explicit?  eg.

struct virtio_net_ctrl_mac {
	__u32 unicast_entries, multicast_entriues;
	__u8 macs[ETH_ALEN][];
} __attribute__((packed));

Might simplify the code a tiny bit, too...

Thanks,
Rusty.
