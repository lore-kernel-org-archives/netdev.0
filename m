From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v2] hyperv: Increase the buffer length for
 netvsc_channel_cb()
Date: Thu, 14 Aug 2014 21:32:38 +0000
Message-ID: <bbf016f1772245a6a08f92ea8346b8ff@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
References: <1407953024-35191-1-git-send-email-haiyangz@microsoft.com>
 <20140814.142856.1220870703473741209.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.89]:39149 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932180AbaHNVcy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:32:54 -0400
In-Reply-To: <20140814.142856.1220870703473741209.davem@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@redhat.com]
> Sent: Thursday, August 14, 2014 5:29 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,v2] hyperv: Increase the buffer length for
> netvsc_channel_cb()
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Wed, 13 Aug 2014 18:03:44 +0000
> 
> > When the buffer is too small for a packet from VMBus, a bigger buffer
> will be
> > allocated in netvsc_channel_cb() and retry reading the packet from
> VMBus.
> > Increasing this buffer size will reduce the retry overhead.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: Dexuan Cui <decui@microsoft.com>
> ...
> > -	net_device = kzalloc(sizeof(struct netvsc_device), GFP_KERNEL);
> > +	net_device = vzalloc(sizeof(*net_device));
> 
> This isn't what I suggested that you do.
> 
> I said that the buffer inside of netvsc_device should be made an
> indirect pointer and thus allocated seperately.
> 
> Thus you're still kzalloc() net_device, but net_device->cb_buffer
> becomes "unsigned char *" and another allocation is made for it.

I will change the patch to this way.
Thanks,

- Haiyang
