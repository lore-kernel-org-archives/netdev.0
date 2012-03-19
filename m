From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 11:30:58 -0700
Message-ID: <1332181858.9397.49.camel@edumazet-glaptop>
References: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
	 <1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
	 <1332177118.9397.32.camel@edumazet-glaptop>
	 <20120319104847.3a4c5fc0@nehalam.linuxnetplumber.net>
	 <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA873@TK5EX14MBXC223.redmond.corp.microsoft.com>
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
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA873@TK5EX14MBXC223.redmond.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-19 at 17:50 +0000, Haiyang Zhang wrote:

> As in my previous reply to Eric --
> We actually stop queue when the ring buffer is busy, see the code in netvsc.c
> 
> I have tested with one CPU. After NETDEV_TX_BUSY is returned, the Linux guest OS
> continues to respond without any problem.

Then something is wrong somewhere.

Dont hide a bug adding a trick.

If you ever return NETDEV_TX_BUSY from start_xmit(), then you MUST call
netif_tx_stop_queue() as well right before.

I believe I already told this before...
