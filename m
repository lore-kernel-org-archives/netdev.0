From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers is racy
 in 3.14+ on Hyper-V 2012 R2
Date: Mon, 14 Jul 2014 22:30:32 +0100
Message-ID: <20140714213032.GA23639@sucs.org>
References: <20140706201800.GA10587@sucs.org>
 <941b0055b1a94c66b3a608ae67764d11@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140707181341.GA2646@sucs.org> <20140711055259.GA10317@sucs.org>
 <52afbe119b1a481aa1c80f909c3a2432@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <52afbe119b1a481aa1c80f909c3a2432@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2014 at 03:25:11PM +0000, Haiyang Zhang wrote:
> 
> > -----Original Message-----
> > From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> > Sent: Friday, July 11, 2014 1:53 AM
> > To: Haiyang Zhang
> > Cc: KY Srinivasan; David S. Miller; devel@linuxdriverproject.org; linux-
> > kernel@vger.kernel.org; netdev@vger.kernel.org
> > Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers is
> > racy in 3.14+ on Hyper-V 2012 R2
> 
> > Oops that should have been
> > https://bugzilla.kernel.org/attachment.cgi?id=142351 (either way it's
> > information linked off
> > https://bugzilla.kernel.org/show_bug.cgi?id=78771 ).
> 
> Thanks for the dmesg. By looking at it, seems the netvsc driver was
> loaded properly, and 2 NICs are up, one NIC is down (probably not set
> to connected in HyperV manager?). Or, this dmesg wasn't the one when
> bug happens?

This was a dmesg where the bug did happen and your first guess is right
- there are 3 NICs but only the first two are connected and the last is
set to "Not connected" in Hyper-V Manager.

> Since you found the commit b679ef73edc is related to this problem,
> could you do a simple test:
>   Reduce the receive buffer size back to 2MB, like below, then re-test
>   it, see if the problem goes away?
> 	drivers/net/hyperv/hyperv_net.h
> 	#define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*2)	/* 2MB */

After doing this I was able to reach over 900 reboots where the network
connected properly.

-- 
Sitsofe | http://sucs.org/~sits/
