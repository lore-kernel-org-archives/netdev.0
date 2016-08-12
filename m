From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [PATCH 2/3] vsockmon: Add vsockmon device.
Date: Fri, 12 Aug 2016 16:17:23 +0200
Message-ID: <a8e4dbec-81fc-e37d-dd7e-309eecd27c69@deic.uab.cat>
References: <20160808161442.16038-1-ggarcia@deic.uab.cat>
 <20160808161442.16038-3-ggarcia@deic.uab.cat>
 <20160810115158.GB10461@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, mst@redhat.com
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33044 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcHLOR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 10:17:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so3119932wme.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 07:17:26 -0700 (PDT)
In-Reply-To: <20160810115158.GB10461@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2016 01:51 PM, Stefan Hajnoczi wrote:
> On Mon, Aug 08, 2016 at 06:14:41PM +0200, ggarcia@abra.uab.cat wrote:
>> diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
>> new file mode 100644
>> index 0000000..739b4bf
>> --- /dev/null
>> +++ b/include/uapi/linux/vsockmon.h
>> @@ -0,0 +1,35 @@
>> +#ifndef _UAPI_VSOCKMON_H
>> +#define _UAPI_VSOCKMON_H
>> +
>> +#include <linux/virtio_vsock.h>
>> +
>> +/* Structure of packets received trought the vsockmon device. */
>> +
>> +struct af_vsockmon_hdr {
>> +	__le64 src_cid;
>> +	__le64 dst_cid;
>> +	__le32 src_port;
>> +	__le32 dst_port;
>> +	__le16 op;			/* enum af_vsockmon_op */
>> +	__le16 t;			/* enum af_vosckmon_t */
>> +	__le16 len;			/* sizeof(t_hdr) */
>> +	union {
>> +		struct virtio_vsock_hdr virtio_hdr;
>> +	} t_hdr;
>> +} __attribute__((packed));
>
> This struct will change in size if/when VMCI transport support is added.
> Existing binaries that were complied against the old header file would
> use an incorrect size.
>
> It would be cleaner to drop t_hdr from the struct and force users to
> explicitly use af_vsockmon_hdr.len to handle the size of the headers.
>

Ok, I'll remove the t_hdr union and put a comment explaining that after 
the vsockmon header there are len bytes of the transport header.
