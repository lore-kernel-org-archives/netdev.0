From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v8 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Thu, 07 Apr 2016 18:15:09 -0700
Message-ID: <1460078109.1800.16.camel@perches.com>
References: <1460079411-31982-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: vkuznets@redhat.com
To: Dexuan Cui <decui@microsoft.com>, gregkh@linuxfoundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
	cavery@redhat.com, kys@microsoft.com, haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460079411-31982-1-git-send-email-decui@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-07 at 18:36 -0700, Dexuan Cui wrote:
> Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
> mechanism between the host and the guest. It's somewhat like TCP over
> VMBus, but the transportation layer (VMBus) is much simpler than IP.
[]
> diff --git a/include/net/af_hvsock.h b/include/net/af_hvsock.h
[]
> +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV (5 * PAGE_SIZE)
> +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_SEND (5 * PAGE_SIZE)
> +
> +#define HVSOCK_RCV_BUF_SZ	VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV
> +#define HVSOCK_SND_BUF_SZ	PAGE_SIZE
[]
> +struct hvsock_sock {
[]
> +	struct {
> +		struct vmpipe_proto_header hdr;
> +		char buf[HVSOCK_SND_BUF_SZ];
> +	} __packed send;
> +
> +	struct {
> +		struct vmpipe_proto_header hdr;
> +		char buf[HVSOCK_RCV_BUF_SZ];
> +		unsigned int data_len;
> +		unsigned int data_offset;
> +	} __packed recv;
> +};

These bufs are not page aligned and so can span pages.

Is there any value in allocating these bufs separately
as pages instead of as a kmalloc?
