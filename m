From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v12 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 28 Jun 2016 09:59:21 +0000
Message-ID: <CO2PR03MB2182CC1DA2804F09D8D77A70BF220@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <BLUPR03MB1410A0ECB526A1CD13814D36BF2E0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160628.053350.1891488485477523405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "vkuznets@redhat.com" <vkuznets@redhat.com>,
 "cavery@redhat.com" <cavery@redhat.com>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160628.053350.1891488485477523405.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, June 28, 2016 17:34
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; vkuznets@redhat.com;
> cavery@redhat.com; KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; joe@perches.com
> Subject: Re: [PATCH v12 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Fri, 24 Jun 2016 07:45:24 +0000
> 
> > +	while ((ret = vmalloc(size)) == NULL)
> > +		ssleep(1);
> 
> This is completely, and entirely, unacceptable.
> 
> If the allocation fails, you return an error and release
> your resources.
> 
> You don't just loop forever waiting for it to succeed.

Hi David,
I agree this is ugly...

The idea here is: IMO the syscalls sys_read()/write() shoudn't return
-ENOMEM, so I have to make sure the buffer allocation succeeds?

I tried to use kmalloc with __GFP_NOFAIL, but I hit a warning in 
in mm/page_alloc.c:
WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));

What error code do you think I should return? 
EAGAIN, ERESTARTSYS, or something else?

May I have your suggestion? Thanks!

-- Dexuan
