From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 13:46:58 -0700
Message-ID: <1332190018.9397.61.camel@edumazet-glaptop>
References: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
	 <1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
	 <1332177118.9397.32.camel@edumazet-glaptop>
	 <20120319104847.3a4c5fc0@nehalam.linuxnetplumber.net>
	 <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA873@TK5EX14MBXC223.redmond.corp.microsoft.com>
	 <1332181858.9397.49.camel@edumazet-glaptop>
	 <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA930@TK5EX14MBXC223.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	KY Srinivasan <kys@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA930@TK5EX14MBXC223.redmond.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-19 at 19:17 +0000, Haiyang Zhang wrote:

> Yes, we called the stop_queue before returning NETDEV_TX_BUSY.
> 
> The stop_queue was called in the function netvsc_send() in file
> netvsc.c, then it returns to rndis_filter_send(), which returns to
> netvsc_start_xmit() in file netvsc_drv.c. So the NETDEV_TX_BUSY is
> indeed returned AFTER queue is stopped.
> 

Thats should be in your changelog, so that next time, reviewers dont
have to spend their time to check you did it right, especially when
start_xmit() code is not self contained or at least in a single file.

Each time we see a NETDEV_TX_BUSY in a patch, this is a sign of a
possible problem.

Your initial changelog was :

Instead of dropping the packet, we keep the skb buffer, and return
NETDEV_TX_BUSY to let upper layer retry send. This will not cause
endless loop, because the host is taking data away from ring buffer.

And this is the typical message that doesnt explain why its safe.
