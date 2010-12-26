From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH v2 1/3] net: implement mechanism for HW
 based QOS
Date: Sun, 26 Dec 2010 15:47:09 -0800
Message-ID: <20101226154709.5b24f976@nehalam>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab>
	<1293009149.3531.12.camel@jlt3.sipsolutions.net>
	<4D12DE47.50200@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43976 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668Ab0LZXrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Dec 2010 18:47:12 -0500
In-Reply-To: <4D12DE47.50200@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Dec 2010 21:29:43 -0800
John Fastabend <john.r.fastabend@intel.com> wrote:

> On 12/22/2010 1:12 AM, Johannes Berg wrote:
> > On Tue, 2010-12-21 at 11:28 -0800, John Fastabend wrote:
> >> This patch provides a mechanism for lower layer devices to
> >> steer traffic using skb->priority to tx queues. This allows
> >> for hardware based QOS schemes to use the default qdisc without
> >> incurring the penalties related to global state and the qdisc
> >> lock. While reliably receiving skbs on the correct tx ring
> >> to avoid head of line blocking resulting from shuffling in
> >> the LLD. Finally, all the goodness from txq caching and xps/rps
> >> can still be leveraged.
> > 
> > Is there any chance this might be applicable to the 802.11 layer as
> > well? We will definitely still need an ndo_select_queue handler to reset
> > in the case where the peer doesn't support QoS, but it seems the part
> > that depends on the frame itself could be pushed out to the generic
> > framework instead of having net/wireless/util.c:cfg80211_classify8021d?
> > 
> > johannes
> > 
> 
> Johannes,
> 
> I took a quick look at this and I believe it should be doable. It would be nice to completely remove the ndo_select_queue if possible though.
> 
> I probably won't have a chance to look any further into this for at least a week maybe two. So I'll think about it a bit more later unless someone else gets there first.
> 
> Thanks,
> John.

The Beceem Wimax driver has same kind of select queue.

-- 
