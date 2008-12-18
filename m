From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] ppp: fix segfaults introduced by netdev_priv changes
Date: Thu, 18 Dec 2008 10:24:43 +0000
Message-ID: <494A24EB.8020307@katalix.com>
References: <200812172202.mBHM2GHi012456@bert.katalix.com> <4949B240.7060102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:57018 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321AbYLRKex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 05:34:53 -0500
In-Reply-To: <4949B240.7060102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:

> I have no comment on these changes, but
> there is a path that calls only ppp_destroy_interface() no
> ppp_shutdown_interface().
> it's:
> ppp_unregister_channel
>     --->ppp_disconnect_channel()
>         ---> ppp_destroy_interface()

Isn't ppp_shutdown_interface() always called first? If not, then we need
to unregister_netdev() before the free_netdev() call in
ppp_destroy_interface(). The original code didn't cover that case.

>>  /*
>> @@ -2616,7 +2614,7 @@ ppp_connect_channel(struct channel *pch, int unit)
>>  	if (pch->file.hdrlen > ppp->file.hdrlen)
>>  		ppp->file.hdrlen = pch->file.hdrlen;
>>  	hdrlen = pch->file.hdrlen + 2;	/* for protocol bytes */
>> -	if (ppp->dev && hdrlen > ppp->dev->hard_header_len)
>> +	if (hdrlen > ppp->dev->hard_header_len)
>>  		ppp->dev->hard_header_len = hdrlen;
>>  	list_add_tail(&pch->clist, &ppp->channels);
>>  	++ppp->n_channels;
> 
> I don't understand this change.
> Do you mean that in this place, ppp->dev will never be NULL?

After my change, yes. See the comment in the patch preamble.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

