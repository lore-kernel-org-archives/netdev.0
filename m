From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 10:27:12 -0700
Message-ID: <44A55EF0.4010307@candelatech.com>
References: <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:16360 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932245AbWF3R1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 13:27:51 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630171348.GI14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Thomas Graf <tgraf@suug.ch> 2006-06-30 18:32
> 
>>Anyways, I give up. Last time I've been running after you trying
>>to fix the many bugs you leave behind. Ever noticed that whenever
>>you add some new code it's someone else following up with tons of
>>small bugfix patches having a hard time trying to figure out the
>>actual intent. I'll just duplicate the code for my purpose, so
>>much easier.
> 
> 
> There you go, leaves ifb broken as-is, at least prevents it
> from crashing randomly when the input_dev disappears.
> 
> [NET]: Use interface index to keep input device information
> 
> Using the interface index instead of a direct reference
> allows a safe usage beyond the scope where an interface
> could disappear.
> 
> The old input_dev field was incorrectly made dependant
> on CONFIG_NET_CLS_ACT in skb_copy().
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

> ===================================================================
> --- net-2.6.git.orig/drivers/net/ifb.c
> +++ net-2.6.git/drivers/net/ifb.c
> @@ -158,19 +158,23 @@ static int ifb_xmit(struct sk_buff *skb,
>  	stats->tx_packets++;
>  	stats->tx_bytes+=skb->len;
>  
> -	if (!from || !skb->input_dev) {
> +	if (!from || !skb->iif) {

Since iif of 0 is valid (afaik), this check is now bogus, eh?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

