From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH resend net] sch_tbf: use do_div() for 64-bit divide
Date: Thu, 12 Dec 2013 10:28:36 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7483@saturn3.aculab.com>
References: <1386814923-56180-1-git-send-email-yangyingliang@huawei.com> <52A92612.5080401@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <fengguang.wu@intel.com>, <kbuild-all@01.org>
To: "Yang Yingliang" <yangyingliang@huawei.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43820 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751155Ab3LLK3m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 05:29:42 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04617-02 for <netdev@vger.kernel.org>;
 Thu, 12 Dec 2013 10:29:40 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52A92612.5080401@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Yang Yingliang
> It's doing a 64-bit divide which is not supported
> on 32-bit architectures in psched_ns_t2l(). The
> correct way to do this is to use do_div().

The 'len' value has just been divided by 1000000000, can
it actually be larger than 32bit when the divide by 53 is done?

...
>  	do_div(len, NSEC_PER_SEC);
> 
> -	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
> -		len = (len / 53) * 48;
> +	if (unlikely(r->linklayer == TC_LINKLAYER_ATM)) {
> +		do_div(len, 53);
> +		len = len * 48;
> +	}

	David
