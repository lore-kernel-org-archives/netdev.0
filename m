From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] vsockmon: Add vsockmon device.
Date: Mon, 15 Aug 2016 10:23:49 -0700 (PDT)
Message-ID: <20160815.102349.379302333828628901.davem@davemloft.net>
References: <20160808161442.16038-3-ggarcia@deic.uab.cat>
	<20160810115158.GB10461@stefanha-x1.localdomain>
	<063D6719AE5E284EB5DD2968C1650D6DB00DC3A8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, ggarcia@abra.uab.cat, netdev@vger.kernel.org,
	jhansen@vmware.com, mst@redhat.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbcHORXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 13:23:50 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00DC3A8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 15 Aug 2016 16:38:36 +0000

> From: Stefan Hajnoczi
>> Sent: 10 August 2016 12:52
>> On Mon, Aug 08, 2016 at 06:14:41PM +0200, ggarcia@abra.uab.cat wrote:
>> > diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
>> > new file mode 100644
>> > index 0000000..739b4bf
>> > --- /dev/null
>> > +++ b/include/uapi/linux/vsockmon.h
>> > @@ -0,0 +1,35 @@
>> > +#ifndef _UAPI_VSOCKMON_H
>> > +#define _UAPI_VSOCKMON_H
>> > +
>> > +#include <linux/virtio_vsock.h>
>> > +
>> > +/* Structure of packets received trought the vsockmon device. */
>> > +
>> > +struct af_vsockmon_hdr {
>> > +	__le64 src_cid;
>> > +	__le64 dst_cid;
>> > +	__le32 src_port;
>> > +	__le32 dst_port;
>> > +	__le16 op;			/* enum af_vsockmon_op */
>> > +	__le16 t;			/* enum af_vosckmon_t */
>> > +	__le16 len;			/* sizeof(t_hdr) */
>> > +	union {
>> > +		struct virtio_vsock_hdr virtio_hdr;
>> > +	} t_hdr;
>> > +} __attribute__((packed));
> ...
> 
> Gah, another 'packed' structure.
> Have you looked at the amount of code the sparc64 compiler generates
> to access the structure members??
> 
> You really want to add another 16bit field and enforce 64bit alignment
> on the header and all data blocks.

Indeed, avoid the packed attribute at all costs.
