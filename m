From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NETFILTER] nfnetlink_log: add sequence numbers for log
 events
Date: Tue, 31 Jan 2006 00:32:21 +0100
Message-ID: <43DEA205.7020704@trash.net>
References: <20060130232348.GH4603@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20060130232348.GH4603@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> Hi Dave,
> 
> please apply, thanks!
> 
> [NETFILTER] nfnetlink_log: add sequence numbers for log events
> 
> By using a sequence number for every logged netfilter event, we can
> determine from userspace whether logging information was lots somewhere
> downstream.

BTW, I have a patch I wanted to submit on top of this, which changes the
*LOG targets to do "reliable" logging, which means if we encounter any
errors during logging (for example from netlink), the packet will be
dropped. This makes as sure as possible that no connections will be
silently accepted. Its a slight change of user-visible behaviour, but
since it only affects corner-cases I think it should be OK. I could add
some flags to retain the current behaviour, but I think its not worth
it. For ULOG its only possible to do this without queueing, so if
qthreshold > 1 we will keep the old behaviour, LOG can't fail anyway.

Any objections?
