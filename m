From: David Miller <davem@davemloft.net>
Subject: Re: [V2 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packet and get the r/w-ability
Date: Wed, 15 Jul 2015 21:16:08 -0700 (PDT)
Message-ID: <20150715.211608.1179325069980931613.davem@davemloft.net>
References: <1436867936-17765-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436867936-17765-1-git-send-email-decui@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 14 Jul 2015 02:58:56 -0700

> +int vmbus_sendpacket_hvsock(struct vmbus_channel *channel, void *buf, u32 len)
> +{
> +	struct vmpacket_descriptor desc;
> +	struct vmpipe_proto_header pipe_hdr;
> +	u32 packetlen;
> +	u32 packetlen_aligned;
> +	struct kvec bufferlist[4];
> +	u64 aligned_data = 0;
> +	int ret;
> +	bool signal = false;

Reverse christmas-tree (longest to shortest line) order these local
variables, please.

> +EXPORT_SYMBOL(vmbus_sendpacket_hvsock);

EXPORT_SYMBOL_GPL()

> +int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
> +				u32 bufferlen, u32 *buffer_actual_len)
> +{
> +	struct vmpacket_descriptor *desc;
> +	struct vmpipe_proto_header *pipe_hdr;
> +	u32 packet_len, payload_len;
> +	int ret;
> +	bool signal = false;

Again, please use reverse christmas-tree order.

> +void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
> +			   bool *can_read, bool *can_write)

Second line is not properly indented, it should start exactly one
column after the openning parenthesis on the previous line.

> +	hv_get_ringbuffer_availbytes(inring_info,
> +				bytes_avail_toread,
> +				bytes_avail_towrite);

Again, improperly indented.

> +extern int vmbus_sendpacket_hvsock(struct vmbus_channel *channel,
> +					void *buf, u32 len);
> +

Likewise.

> +extern int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
> +				u32 bufferlen, u32 *buffer_actual_len);
> +
> +extern void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
> +			   bool *can_read, bool *can_write);

Likewise.
