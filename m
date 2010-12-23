From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 1/3] net: implement mechanism for HW based
 QOS
Date: Wed, 22 Dec 2010 21:29:43 -0800
Message-ID: <4D12DE47.50200@intel.com>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab> <1293009149.3531.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64826 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab0LWF3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 00:29:47 -0500
In-Reply-To: <1293009149.3531.12.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2010 1:12 AM, Johannes Berg wrote:
> On Tue, 2010-12-21 at 11:28 -0800, John Fastabend wrote:
>> This patch provides a mechanism for lower layer devices to
>> steer traffic using skb->priority to tx queues. This allows
>> for hardware based QOS schemes to use the default qdisc without
>> incurring the penalties related to global state and the qdisc
>> lock. While reliably receiving skbs on the correct tx ring
>> to avoid head of line blocking resulting from shuffling in
>> the LLD. Finally, all the goodness from txq caching and xps/rps
>> can still be leveraged.
> 
> Is there any chance this might be applicable to the 802.11 layer as
> well? We will definitely still need an ndo_select_queue handler to reset
> in the case where the peer doesn't support QoS, but it seems the part
> that depends on the frame itself could be pushed out to the generic
> framework instead of having net/wireless/util.c:cfg80211_classify8021d?
> 
> johannes
> 

Johannes,

I took a quick look at this and I believe it should be doable. It would be nice to completely remove the ndo_select_queue if possible though.

I probably won't have a chance to look any further into this for at least a week maybe two. So I'll think about it a bit more later unless someone else gets there first.

Thanks,
John.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

