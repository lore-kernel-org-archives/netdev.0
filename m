From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
Date: Fri, 06 May 2016 13:03:53 -0400 (EDT)
Message-ID: <20160506.130353.2082047339292515860.davem@davemloft.net>
References: <1462381017-568-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, joe@perches.com, netdev@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1462381017-568-1-git-send-email-decui@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Wed,  4 May 2016 09:56:57 -0700

> +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV (5 * PAGE_SIZE)
> +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_SEND (5 * PAGE_SIZE)
> +
> +#define HVSOCK_RCV_BUF_SZ	VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV
 ...
> +struct hvsock_sock {
 ...
> +	/* The 'hdr' and 'buf' in the below 'send' and 'recv' definitions must
> +	 * be consecutive: see hvsock_send_data() and hvsock_recv_data().
> +	 */
> +	struct {
> +		struct vmpipe_proto_header hdr;
> +		u8 buf[HVSOCK_SND_BUF_SZ];
> +	} send;
> +
> +	struct {
> +		struct vmpipe_proto_header hdr;
> +		u8 buf[HVSOCK_RCV_BUF_SZ];
> +
> +		unsigned int data_len;
> +		unsigned int data_offset;
> +	} recv;

I don't think allocating 5 pages of unswappable memory for every Hyper-V socket
created is reasonable.
