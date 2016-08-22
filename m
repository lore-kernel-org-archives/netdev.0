From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [PATCH 2/3] vsockmon: Add vsockmon device.
Date: Mon, 22 Aug 2016 12:12:29 +0200
Message-ID: <e4245972-d695-c9cd-e06d-33473c5fcfbd@deic.uab.cat>
References: <20160808161442.16038-3-ggarcia@deic.uab.cat> <"20160810115158.GB1
 0461"@stefanha-x1.localdomain>
 <20160815.102349.379302333828628901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, netdev@vger.kernel.org, jhansen@vmware.com,
        mst@redhat.com
To: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32854 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbcHVKMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:12:32 -0400
Received: by mail-wm0-f65.google.com with SMTP id o80so12710276wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 03:12:32 -0700 (PDT)
In-Reply-To: <20160815.102349.379302333828628901.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2016 07:23 PM, David Miller wrote:
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Mon, 15 Aug 2016 16:38:36 +0000
>
>> From: Stefan Hajnoczi
>>> Sent: 10 August 2016 12:52
>>> On Mon, Aug 08, 2016 at 06:14:41PM +0200, ggarcia@abra.uab.cat wrote:
>>>> diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
>>>> new file mode 100644
>>>> index 0000000..739b4bf
>>>> --- /dev/null
>>>> +++ b/include/uapi/linux/vsockmon.h
>>>> @@ -0,0 +1,35 @@
>>>> +#ifndef _UAPI_VSOCKMON_H
>>>> +#define _UAPI_VSOCKMON_H
>>>> +
>>>> +#include <linux/virtio_vsock.h>
>>>> +
>>>> +/* Structure of packets received trought the vsockmon device. */
>>>> +
>>>> +struct af_vsockmon_hdr {
>>>> +	__le64 src_cid;
>>>> +	__le64 dst_cid;
>>>> +	__le32 src_port;
>>>> +	__le32 dst_port;
>>>> +	__le16 op;			/* enum af_vsockmon_op */
>>>> +	__le16 t;			/* enum af_vosckmon_t */
>>>> +	__le16 len;			/* sizeof(t_hdr) */
>>>> +	union {
>>>> +		struct virtio_vsock_hdr virtio_hdr;
>>>> +	} t_hdr;
>>>> +} __attribute__((packed));
>> ...
>>
>> Gah, another 'packed' structure.
>> Have you looked at the amount of code the sparc64 compiler generates
>> to access the structure members??
>>
>> You really want to add another 16bit field and enforce 64bit alignment
>> on the header and all data blocks.
>
> Indeed, avoid the packed attribute at all costs.
>

I understand. I'll add another 16b field so it is aligned and avoid the 
packed attribute.

Gerard
