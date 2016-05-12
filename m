From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] vxlan: set mac_header correctly in GPE mode
Date: Thu, 12 May 2016 11:07:45 +0200
Message-ID: <20160512110745.6b6ab063@griffin>
References: <3b9c5ffd8085c0af7072960865883a23be0d0a32.1462974886.git.jbenc@redhat.com>
	<20160512094758.32bd517c@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988AbcELJHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 05:07:49 -0400
In-Reply-To: <20160512094758.32bd517c@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 May 2016 09:47:58 +0300, Shmulik Ladkani wrote:
> Would it make sense to perform this within __iptunnel_pull_header (in
> case raw_proto is true) for all __iptunnel_pull_header callers?

raw_proto just denotes that inner_proto of ETH_P_TEB should not be
treated specially. Guessing any other special meaning based on this
flag would be unexpected and confusing. Specifically,
__iptunnel_pull_header doesn't have and should not have any notion of
the device type; although all current users of raw_proto == true are of
ARPHRD_NONE type, it's not a requirement.

> If not (meaning vxlan specific), in next few lines we have:
> 
> 	if (!raw_proto) {
> 		if (!vxlan_set_mac(vxlan, vs, skb))
> 			goto drop;
> 	} else {
> 		skb->dev = vxlan->dev;
> 		skb->pkt_type = PACKET_HOST;
> 	}
> 
> Seems more appropriate to place the missing 'skb_reset_mac_header'
> within the "else" part, which logically holds all "things to initialize
> in the skb if raw_proto is true, thus havn't called vxlan_set_mac".

I agree. I'll respin the patch.

Thanks!

 Jiri
