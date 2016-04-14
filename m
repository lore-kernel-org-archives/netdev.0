From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v8 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Thu, 14 Apr 2016 03:56:27 +0000
Message-ID: <BLUPR03MB14101CD61AF994F61656CD3ABF970@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1460079411-31982-1-git-send-email-decui@microsoft.com>
 <20160413.223027.844777521863481943.davem@davemloft.net>
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
 Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160413.223027.844777521863481943.davem@davemloft.net>
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
> Sent: Thursday, April 14, 2016 10:30
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; cavery@redhat.com; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> joe@perches.com; vkuznets@redhat.com
> Subject: Re: [PATCH v8 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Thu,  7 Apr 2016 18:36:51 -0700
> 
> > +struct vmpipe_proto_header {
> > +	u32 pkt_type;
> > +	u32 data_size;
> > +} __packed;
> 
> There is no reason to specify __packed here.
> 
> The types are strongly sized to word aligned quantities.
> No holes are possible in this structure, nor is any padding
> possible either.
> 
> Do not ever slap __packed onto protocol or HW defined structures,
> simply just define them properly with proper types and explicit
> padding when necessary.

Hi David,
Thank you very much for taking a look at the patch!
I'll remove all the 3 __packed usages in my patch.

> > +	struct {
> > +		struct vmpipe_proto_header hdr;
> > +		char buf[HVSOCK_SND_BUF_SZ];
> > +	} __packed send;
> 
> And so on, and so forth..
I'll remove __packed and use u8 to replace the 'char' here.
 
> I'm really disappointed that I couldn't even get one hunk into this
> patch submission without finding a major problem.
David,
Could you please point out more issues in the patch? 
I'm definitely happy to fix them. :-)
 
> I expect this patch to take several more iterations before I can even
> come close to applying it.  So please set your expectations properly,
> and also it seems like nobody else wants to even review this stuff
> either.  It is you who needs to find a way to change all of this, not
> me.

A few people took a look at the early versions of the patch and did
give me good suggestions on the interface APIs with VMBus and
some coding style issues, especially Vitaly from Redhat.

Cathy from Redhat was also looking into the patch recently and
gave me some good feedbacks.

I'll try to invite more people to review the patch.

And, I'm updating the patch to address some issues:

1) the feature is only properly supported on Windows 10/2016
build 14290 and later, so I'm going to not enable the feature on
old hosts.

2) there is actually some mechanism we can use to simplify 
hvsock_open_connection() and help to better support 
hvsock_shutdown().

Thanks,
-- Dexuan
