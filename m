From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [BISECTED][REGRESSION] Loading Hyper-V network drivers is racy
 in 3.14+ on Hyper-V 2012 R2
Date: Fri, 11 Jul 2014 15:25:11 +0000
Message-ID: <52afbe119b1a481aa1c80f909c3a2432@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <20140706201800.GA10587@sucs.org>
 <941b0055b1a94c66b3a608ae67764d11@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140707181341.GA2646@sucs.org> <20140711055259.GA10317@sucs.org>
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
In-Reply-To: <20140711055259.GA10317@sucs.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> Sent: Friday, July 11, 2014 1:53 AM
> To: Haiyang Zhang
> Cc: KY Srinivasan; David S. Miller; devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers is
> racy in 3.14+ on Hyper-V 2012 R2

> Oops that should have been
> https://bugzilla.kernel.org/attachment.cgi?id=142351 (either way it's
> information linked off
> https://bugzilla.kernel.org/show_bug.cgi?id=78771 ).

Thanks for the dmesg. By looking at it, seems the netvsc driver was loaded properly, and 2 NICs are up, one NIC is down (probably not set to connected in HyperV manager?). Or, this dmesg wasn't the one when bug happens?

[    8.514493] hv_netvsc: hv_netvsc channel opened successfully
[    9.343318] hv_netvsc vmbus_0_14: Send section size: 6144, Section count:170
[    9.345831] hv_netvsc vmbus_0_14: Device MAC 00:15:5d:6f:02:8f link state up

[    9.347101] hv_netvsc: hv_netvsc channel opened successfully
[   10.170308] hv_netvsc vmbus_0_15: Send section size: 6144, Section count:170
[   10.170702] hv_netvsc vmbus_0_15: Device MAC 00:15:5d:6f:02:a5 link state up

[   10.172826] hv_netvsc: hv_netvsc channel opened successfully
[   10.988146] hv_netvsc vmbus_0_16: Send section size: 6144, Section count:170
[   10.989069] hv_netvsc vmbus_0_16: Device MAC 00:15:5d:6f:02:a6 link state down

Since you found the commit b679ef73edc is related to this problem, could you do a simple test:
  Reduce the receive buffer size back to 2MB, like below, then re-test it, see if the problem goes away?
	drivers/net/hyperv/hyperv_net.h
	#define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*2)	/* 2MB */

Thanks,
- Haiyang
