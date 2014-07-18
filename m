From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [BISECTED][REGRESSION] Loading Hyper-V network drivers is racy
 in 3.14+ on Hyper-V 2012 R2
Date: Fri, 18 Jul 2014 21:30:49 +0000
Message-ID: <e72aea6f4eab48e6851fdc4d32b89fa2@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <20140706201800.GA10587@sucs.org>
 <941b0055b1a94c66b3a608ae67764d11@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140707181341.GA2646@sucs.org> <20140711055259.GA10317@sucs.org>
 <52afbe119b1a481aa1c80f909c3a2432@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140714213032.GA23639@sucs.org>
 <8b68f48141a045f784c10f9c081cd51f@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140715050832.GA28549@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"David S. Miller" <davem@davemloft.net>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sitsofe Wheeler <sitsofe@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140715050832.GA28549@sucs.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> Sent: Tuesday, July 15, 2014 1:09 AM
> To: Haiyang Zhang
> Cc: KY Srinivasan; David S. Miller; devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers is
> racy in 3.14+ on Hyper-V 2012 R2
> 
> On Mon, Jul 14, 2014 at 10:39:48PM +0000, Haiyang Zhang wrote:
> > > -----Original Message-----
> > > From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> > > Sent: Monday, July 14, 2014 5:31 PM
> > > To: Haiyang Zhang
> > > Cc: KY Srinivasan; David S. Miller; devel@linuxdriverproject.org;
> linux-
> > > kernel@vger.kernel.org; netdev@vger.kernel.org
> > > Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers
> is
> > > racy in 3.14+ on Hyper-V 2012 R2
> >
> > Thanks for the tests! I will make a patch that can automatically retry
> > smaller memory allocs when memory is insufficient.
> 
> This concerns me a bit - why would there be insufficient memory on a 64
> bit VM with 4 GBytes of RAM just after startup (presumably the host's
> memory isn't the issue)? Additionally, while things might fail just when
> things are starting up, doing ifup eth0 at some point later succeeds so
> whatever issue it had seems temporary.
> 
> Perhaps it would be wise to adding some debugging output to see if the
> allocation really failed and why...

Actually, there will be debug log in dmesg if the memory allocation fails. 
But it didn't show up in your dmesg. And since it can be recovered by 
"ifup eth0" later, the NIC must have been properly loaded (buffer alloc was 
successful but took a bit longer time). I think the larger receive-buffer 
size (16MB) may take longer time, because vzalloc() may sleep. And, that's 
why we don't see the bug with a small buffer size, because the allocation 
is quick.

Could you try put "LINKDELAY=60" into the this file?
	/etc/sysconfig/network-scripts/ifcfg-eth0
And see if the problem goes away?

Thanks,
- Haiyang
