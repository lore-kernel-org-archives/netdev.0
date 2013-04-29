From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Fix a compiler warning in netvsc_send()
Date: Mon, 29 Apr 2013 18:30:53 +0000
Message-ID: <2bef79e083dd4b14adc5e6d3549f8a05@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1367000755-2571-1-git-send-email-haiyangz@microsoft.com>
 <20130429.140932.1477434738582260564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130429.140932.1477434738582260564.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, April 29, 2013 2:10 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Fix a compiler warning in
> netvsc_send()
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Fri, 26 Apr 2013 11:25:55 -0700
> 
> > Fixed: warning: cast from pointer to integer of different size
> >
> > The Hyper-V hosts always use 64 bit request id. The guests can have 32
> > or 64 bit pointers which equal to the ulong type size. So we cast it to ulong
> type.
> > And, assigning 32bit integer to 64 bit variable works fine.
> >
> > The VMBus returns the same id in the completion packet. But the value
> > has no effect on the host side.
> >
> > Reported-by: kbuild test robot <fengguang.wu@intel.com>
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> Applied, but:
> 
> > -		req_id = (u64)packet;
> > +		req_id = (ulong)packet;
> 
> I really do not like these shorthands for fundamental C types, we generally
> do not use "ulong", "uint" etc.  Please expand them out explicitly to
> "unsigned long", "unsigned int", etc.

Thanks for applying it. 

Going forward, I will use the long format, like "unsigned long", instead of "ulong", etc.

Thanks,
- Haiyang
