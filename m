From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Mon, 25 Aug 2014 17:34:27 +0000
Message-ID: <cf94fd58947d4c5aa6d0d369c1126d7f@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <20140819123655.GC12160@sucs.org> <20140825093648.GB5046@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jason Wang <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Sitsofe Wheeler <sitsofe@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140825093648.GB5046@mwanda>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Monday, August 25, 2014 2:37 AM
> To: Sitsofe Wheeler
> Cc: KY Srinivasan; Greg Kroah-Hartman; Jason Wang; linux-
> kernel@vger.kernel.org; David S. Miller; Daniel Borkmann;
> netdev@vger.kernel.org; devel@linuxdriverproject.org; Haiyang Zhang
> Subject: Re: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
> 
> The code here is:
> 
> drivers/hv/channel.c
>    460          BUG_ON(ret != 0);
>    461          t = wait_for_completion_timeout(&info->waitevent, 5*HZ);
>    462          BUG_ON(t == 0);
> 
> So it calls BUG_ON() if the teardown takes more than 5 seconds.  It's most
> likely that there is a race condition somewhere.  It's also possible that it's just
> taking longer than 5 seconds for some odd reason and the bug would go
> away if we raised it to 60 seconds.
> 
> BUG_ON() after 5 seconds seems like a very aggressive thing.

Dan,

I am going to audit all BUG_ON() instances.

Thanks,

K. Y
> 
> regards,
> dan carpenter
