From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v8 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Fri, 8 Apr 2016 01:56:06 +0000
Message-ID: <BLUPR03MB1410C2ECCBDEFC62CDA9928CBF910@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1460079411-31982-1-git-send-email-decui@microsoft.com>
 <1460078109.1800.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "davem@davemloft.net" <davem@davemloft.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>, "cavery@redhat.com"
 <cavery@redhat.com>, KY Srinivasan <kys@microsoft.com>, Haiyang Zhang
 <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460078109.1800.16.camel@perches.com>
Content-Language: en-US
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

> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, April 8, 2016 9:15
> On Thu, 2016-04-07 at 18:36 -0700, Dexuan Cui wrote:
> > diff --git a/include/net/af_hvsock.h b/include/net/af_hvsock.h
> []
> > +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV (5 * PAGE_SIZE)
> > +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_SEND (5 * PAGE_SIZE)
> > +
> > +#define HVSOCK_RCV_BUF_SZ
> 	VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV
> > +#define HVSOCK_SND_BUF_SZ	PAGE_SIZE
> []
> > +struct hvsock_sock {
> []
> > +	struct {
> > +		struct vmpipe_proto_header hdr;
> > +		char buf[HVSOCK_SND_BUF_SZ];
> > +	} __packed send;
> > +
> > +	struct {
> > +		struct vmpipe_proto_header hdr;
> > +		char buf[HVSOCK_RCV_BUF_SZ];
> > +		unsigned int data_len;
> > +		unsigned int data_offset;
> > +	} __packed recv;
> > +};
> 
> These bufs are not page aligned and so can span pages.
> 
> Is there any value in allocating these bufs separately
> as pages instead of as a kmalloc?

The bufs are not required to be page aligned.
Here the 'hdr' and the 'buf' must be consecutive, i.e., the 'buf' must be
an array rather than a pointer: please see hvsock_send_data().

It looks to me there is no big value to make sure the 'buf' is page
aligned: on x86_64, at least it should already be 8-byte aligned due to the
adjacent channel pointer, so memcpy_from_msg() should work
enough good and in hvsock_send_data() -> vmbus_sendpacket(),
we don't copy the 'buf'.

Thanks,
-- Dexuan
