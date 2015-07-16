From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [V2 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock packet
 and get the r/w-ability
Date: Thu, 16 Jul 2015 11:18:52 +0000
Message-ID: <5b373066598044ae8a15a87e99e485c6@SIXPR30MB031.064d.mgd.msft.net>
References: <1436867936-17765-1-git-send-email-decui@microsoft.com>
 <20150715.211608.1179325069980931613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150715.211608.1179325069980931613.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller
> Sent: Thursday, July 16, 2015 12:16
> 
> From: Dexuan Cui
> Date: Tue, 14 Jul 2015 02:58:56 -0700
> 
> > +int vmbus_sendpacket_hvsock(struct vmbus_channel *channel, void *buf,
> u32 len)
> > +{
> > +	struct vmpacket_descriptor desc;
> > +	struct vmpipe_proto_header pipe_hdr;
> > +	u32 packetlen;
> > +	u32 packetlen_aligned;
> > +	struct kvec bufferlist[4];
> > +	u64 aligned_data = 0;
> > +	int ret;
> > +	bool signal = false;
> 
> Reverse christmas-tree (longest to shortest line) order these local
> variables, please.
OK.

> 
> > +EXPORT_SYMBOL(vmbus_sendpacket_hvsock);
> 
> EXPORT_SYMBOL_GPL()
Oh, sorry. I'll fix it.
 
> > +int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
> > +				u32 bufferlen, u32 *buffer_actual_len)
> > +{
> > +	struct vmpacket_descriptor *desc;
> > +	struct vmpipe_proto_header *pipe_hdr;
> > +	u32 packet_len, payload_len;
> > +	int ret;
> > +	bool signal = false;
> 
> Again, please use reverse christmas-tree order.
OK.


> > +void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
> > +			   bool *can_read, bool *can_write)
> 
> Second line is not properly indented, it should start exactly one
> column after the openning parenthesis on the previous line.
OK.
I didn't realize this issue. Thanks for reminding me!
The patch did pass the check of scripts/checkpatch.pl. :-)
I found scripts/Lindent can detect such kind of issue.
I'll run scripts/Lindent against my code and fix all of them in V3.

> > +	hv_get_ringbuffer_availbytes(inring_info,
> > +				bytes_avail_toread,
> > +				bytes_avail_towrite);
> 
> Again, improperly indented.
OK. will fix it.

> > +extern int vmbus_sendpacket_hvsock(struct vmbus_channel *channel,
> > +					void *buf, u32 len);
> > +
> 
> Likewise.
OK. will fix it.

> > +extern int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void
> *buffer,
> > +				u32 bufferlen, u32 *buffer_actual_len);
> > +
> > +extern void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
> > +			   bool *can_read, bool *can_write);
> 
> Likewise.
OK. will fix it.

-- Dexuan
