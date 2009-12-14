From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 2/4] Defer skb allocation -- new skb_set calls & chain pages in virtio_net
Date: Mon, 14 Dec 2009 17:24:48 +1030
Message-ID: <200912141724.49034.rusty@rustcorp.com.au>
References: <1258697359.7416.14.camel@localhost.localdomain> <1260534506.30371.6.camel@localhost.localdomain> <1260535382.30371.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753730AbZLNGy5@vger.kernel.org>
In-Reply-To: <1260535382.30371.20.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Dec 2009 11:13:02 pm Shirley Ma wrote:
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

I don't think there's a good way of splitting this change across multiple
patches.  And I don't think this patch will compile; I don't think we can
get rid of trim_pages yet.

We *could* first split the receive paths into multiple parts as you have
(eg. add_recvbuf_big etc), then actually rewrite them, but that's too much
work to refactor the code twice.  

So just roll all the driver changes into one patch; so you will have two
patches: one which creates the destroy_bufs API for virtio, and one which
uses it in the virtio_net driver.

> +static struct sk_buff *skb_goodcopy(struct virtnet_info *vi, struct page **page,
> +				    unsigned int *len)

This actually allocates an skb, and transfers the first page to it (via copy
and possibly the first fragment).  skb_from_page() perhaps?

> +		hdr_len = sizeof(hdr->hdr);
> +		offset = sizeof(struct padded_vnet_hdr);
> +	}
> +
> +	memcpy(hdr, p, hdr_len);
> +
> +	*len -= hdr_len;

Perhaps you should return NULL here as an error if *len was < hdr_len?

Thanks,
Rusty.
