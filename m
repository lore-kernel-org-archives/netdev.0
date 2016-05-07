From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
Date: Sat, 7 May 2016 10:49:25 +0000
Message-ID: <BLUPR03MB1410F30AED34632F8F1268DEBF7E0@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1462381017-568-1-git-send-email-decui@microsoft.com>
 <20160506.130353.2082047339292515860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"cavery@redhat.com" <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0147.outbound.protection.outlook.com ([157.56.110.147]:33795
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750786AbcEGKta convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 06:49:30 -0400
In-Reply-To: <20160506.130353.2082047339292515860.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, May 7, 2016 1:04
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; cavery@redhat.com; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> joe@perches.com; vkuznets@redhat.com
> Subject: Re: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Wed,  4 May 2016 09:56:57 -0700
> 
> > +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV (5 * PAGE_SIZE)
> > +#define VMBUS_RINGBUFFER_SIZE_HVSOCK_SEND (5 * PAGE_SIZE)
> > +
> > +#define HVSOCK_RCV_BUF_SZ
> 	VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV
>  ...
> > +struct hvsock_sock {
>  ...
> > +	/* The 'hdr' and 'buf' in the below 'send' and 'recv' definitions must
> > +	 * be consecutive: see hvsock_send_data() and hvsock_recv_data().
> > +	 */
> > +	struct {
> > +		struct vmpipe_proto_header hdr;
> > +		u8 buf[HVSOCK_SND_BUF_SZ];
> > +	} send;
> > +
> > +	struct {
> > +		struct vmpipe_proto_header hdr;
> > +		u8 buf[HVSOCK_RCV_BUF_SZ];
> > +
> > +		unsigned int data_len;
> > +		unsigned int data_offset;
> > +	} recv;
> 
> I don't think allocating 5 pages of unswappable memory for every Hyper-V
> socket
> created is reasonable.

Thanks for the comment, David!

I should be able to make 'send', 'recv' here to pointers and use vmalloc()
to allocate the memory for them.  I will do this.

Thanks,
-- Dexuan
