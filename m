From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: Re: [RESEND PATCH] net: introduce helper macra CMSG_FOREACH_HDR
Date: Fri, 5 Dec 2014 16:29:07 +0800
Message-ID: <54816CD3.90107@cn.fujitsu.com>
References: <54815B40.1050909@cn.fujitsu.com> <1417766552.2721.45.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417766552.2721.45.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,
Thanks for your comment.
On 12/05/2014 04:02 PM, Joe Perches wrote:

> On Fri, 2014-12-05 at 15:14 +0800, Gu Zheng wrote:
>> Introduce helper macra
> 
> macro

Ah~, it's a typo.

> 
>> CMSG_FOREACH_HDR as a wrapper of the enumerating
>> cmsghdr from msghdr, just cleanup. 
> 
> maybe better to use lower case "for_each_cmsg_hdr"
> or some such.

But this will make it out of the ordinary, as the existed ones
are all upper.

David, what's your opinion?

Regards,
Gu

> 
> checkpatch would recognize that too as long as it
> uses "for_each".
> 
>> diff --git a/include/linux/socket.h b/include/linux/socket.h
> []
>> @@ -94,6 +94,10 @@ struct cmsghdr {
>>  			     (cmsg)->cmsg_len <= (unsigned long) \
>>  			     ((mhdr)->msg_controllen - \
>>  			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
>> +#define CMSG_FOREACH_HDR(cmsg, msg)  \
>> +	for (cmsg = CMSG_FIRSTHDR(msg); \
>> +	     cmsg; \
>> +	     cmsg = CMSG_NXTHDR(msg, cmsg))
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
