From: Joe Perches <joe@perches.com>
Subject: Re: [RESEND PATCH] net: introduce helper macra CMSG_FOREACH_HDR
Date: Fri, 05 Dec 2014 00:02:32 -0800
Message-ID: <1417766552.2721.45.camel@perches.com>
References: <54815B40.1050909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54815B40.1050909@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-12-05 at 15:14 +0800, Gu Zheng wrote:
> Introduce helper macra

macro

> CMSG_FOREACH_HDR as a wrapper of the enumerating
> cmsghdr from msghdr, just cleanup. 

maybe better to use lower case "for_each_cmsg_hdr"
or some such.

checkpatch would recognize that too as long as it
uses "for_each".

> diff --git a/include/linux/socket.h b/include/linux/socket.h
[]
> @@ -94,6 +94,10 @@ struct cmsghdr {
>  			     (cmsg)->cmsg_len <= (unsigned long) \
>  			     ((mhdr)->msg_controllen - \
>  			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
> +#define CMSG_FOREACH_HDR(cmsg, msg)  \
> +	for (cmsg = CMSG_FIRSTHDR(msg); \
> +	     cmsg; \
> +	     cmsg = CMSG_NXTHDR(msg, cmsg))
