From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] vsockmon: Add vsockmon device.
Date: Mon, 15 Aug 2016 16:38:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00DC3A8@AcuExch.aculab.com>
References: <20160808161442.16038-1-ggarcia@deic.uab.cat>
 <20160808161442.16038-3-ggarcia@deic.uab.cat>
 <20160810115158.GB10461@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jhansen@vmware.com" <jhansen@vmware.com>,
	"mst@redhat.com" <mst@redhat.com>
To: 'Stefan Hajnoczi' <stefanha@redhat.com>,
	"ggarcia@abra.uab.cat" <ggarcia@abra.uab.cat>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:58842 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbcHOQk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 12:40:59 -0400
In-Reply-To: <20160810115158.GB10461@stefanha-x1.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi
> Sent: 10 August 2016 12:52
> On Mon, Aug 08, 2016 at 06:14:41PM +0200, ggarcia@abra.uab.cat wrote:
> > diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
> > new file mode 100644
> > index 0000000..739b4bf
> > --- /dev/null
> > +++ b/include/uapi/linux/vsockmon.h
> > @@ -0,0 +1,35 @@
> > +#ifndef _UAPI_VSOCKMON_H
> > +#define _UAPI_VSOCKMON_H
> > +
> > +#include <linux/virtio_vsock.h>
> > +
> > +/* Structure of packets received trought the vsockmon device. */
> > +
> > +struct af_vsockmon_hdr {
> > +	__le64 src_cid;
> > +	__le64 dst_cid;
> > +	__le32 src_port;
> > +	__le32 dst_port;
> > +	__le16 op;			/* enum af_vsockmon_op */
> > +	__le16 t;			/* enum af_vosckmon_t */
> > +	__le16 len;			/* sizeof(t_hdr) */
> > +	union {
> > +		struct virtio_vsock_hdr virtio_hdr;
> > +	} t_hdr;
> > +} __attribute__((packed));
...

Gah, another 'packed' structure.
Have you looked at the amount of code the sparc64 compiler generates
to access the structure members??

You really want to add another 16bit field and enforce 64bit alignment
on the header and all data blocks.

	David
