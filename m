From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [patch] net: remove an unneeded check
Date: Mon, 5 Aug 2013 18:18:01 +0000
Message-ID: <F3E01662-FC33-4FB8-AF30-47DF44252296@intel.com>
References: <20130729191519.GA11874@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<kernel-janitors@vger.kernel.org>" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30348 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab3HESSC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:18:02 -0400
In-Reply-To: <20130729191519.GA11874@elgon.mountain>
Content-Language: en-US
Content-ID: <9118E931EEE58247B9E1459C3EA3D3A7@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jul 29, 2013, at 12:15 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:

> "ifa->ifa_label" is an array inside the in_ifaddr struct.  It can never
> be NULL so we can remove this check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 8d48c39..1b7f7ae 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1124,10 +1124,7 @@ static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
> 		if (len < (int) sizeof(ifr))
> 			break;
> 		memset(&ifr, 0, sizeof(struct ifreq));
> -		if (ifa->ifa_label)

Is there any possibility that this was meant to check ifa->ifa_label[0]?

> -			strcpy(ifr.ifr_name, ifa->ifa_label);
> -		else
> -			strcpy(ifr.ifr_name, dev->name);
> +		strcpy(ifr.ifr_name, ifa->ifa_label);
> 
> 		(*(struct sockaddr_in *)&ifr.ifr_addr).sin_family = AF_INET;
> 		(*(struct sockaddr_in *)&ifr.ifr_addr).sin_addr.s_addr =

-- 
Mark Rustad, Networking Division, Intel Corporation
