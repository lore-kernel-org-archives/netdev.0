From: Joe Perches <joe@perches.com>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 03:41:24 -0700
Message-ID: <1349865684.2386.30.camel@joe-AO722>
References: <20121010093816.GA3669@elgon.mountain>
	 <1349864358.2386.27.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54930 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755165Ab2JJKlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 06:41:24 -0400
In-Reply-To: <1349864358.2386.27.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 03:19 -0700, Joe Perches wrote:
> diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
[]
>  	struct isdn_ppp_comp_data data;
> @@ -589,16 +589,15 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
>  		break;
>  	case PPPIOCGCOMPRESSORS:
>  	{
> -		unsigned long protos[8] = {0,};
> +		DECLARE_BITMAP(protos, BITS_PER_LONG * 8) = { 0, };

s/BITS_PER_LONG/sizeof(long)/duh...
