From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2] ip xfrm: support 64bit kernel and 32bit
 userspace
Date: Fri, 28 Nov 2014 10:47:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9FE52D@AcuExch.aculab.com>
References: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "'roy.qing.li@gmail.com'" <roy.qing.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45973 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751176AbaK1KtR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 05:49:17 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00339-04 for <netdev@vger.kernel.org>;
 Fri, 28 Nov 2014 10:49:08 +0000 (GMT)
In-Reply-To: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The size of struct xfrm_userpolicy_info is 168 bytes for 64bit kernel, and
> 164 bytes for 32bit userspace because of the different alignment. and lead
> to "ip xfrm" be unable to work.
> 
> add a pad in struct xfrm_userpolicy_info, and enable it by set
> KERNEL_64_USERSPACE_32 to y
...
> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> index fa2ecb2..009510c 100644
> --- a/include/linux/xfrm.h
> +++ b/include/linux/xfrm.h
> @@ -407,6 +407,9 @@ struct xfrm_userpolicy_info {
>  	/* Automatically expand selector to include matching ICMP payloads. */
>  #define XFRM_POLICY_ICMP	2
>  	__u8				share;
> +#ifdef KNL_64_US_32
> +	int				pad;
> +#endif
>  };

You could add __attribute__((aligned(8))) to the structure to pad it on
all systems.

Or find the 64bit member and add __attribute__((aligned(4))) to that member
so that the 64bit version doesn't get padded.
That will make the field more expensive to access on systems that can't
do misaligned memory transfers.

	David
