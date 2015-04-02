From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Thu, 02 Apr 2015 13:39:27 -0500
Message-ID: <1427999967.5282.39.camel@redhat.com>
References: <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
	 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
	 <20150402.141623.717255772856055027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org, jbenc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbbDBSjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 14:39:06 -0400
In-Reply-To: <20150402.141623.717255772856055027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-02 at 14:16 -0400, David Miller wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Mon, 30 Mar 2015 23:22:50 -0500
> 
> > +	case htons(ETH_P_ALL): {
> > +		/* Raw sockets */
> > +		if (eth_hdr(skb)->h_proto != htons(ETH_P_IP))
> > +			break;
> > +		/* Fall through */
> > +	}
> 
> You are not declaring any local variables in this switch block, therefore
> there is no reason to surround it with curly braces, remove them.
> 
> > +	if (skb->len < DHCP_PACKET_MIN_LEN || ip4h->protocol != IPPROTO_UDP
> > +		|| ip_is_fragment(ip4h))
> > +		return false;
> 
> This is not formatted properly.
> 
> Lines of conditional statements _END_ with operators, they should never
> begin with one.
> 
> Also, the second and subsequent lines of a multi-line if() statement should
> begin precisely at the first column after the openning parenthesis of the
> first line.  You must use the appropriate number of TAB then SPACE characters
> to achieve this.
> 
> If you are purely using TAB characters to indent these things, it is almost
> certain that you are doing it wrong.
> 
> And yes, I am super sick of typing this in several times a day, especially
> when this is not only documented, but checked for by checkpatch and other
> automated tools.
> 
> > +	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
> > +	if (!ipvlan->dhcp4_seen && lyr3h && addr_type == IPVL_IPV4
> > +	    && is_dhcp(skb)) {
> 
> Likewise.

I'm sorry about that, and I will fix style/indent and re-post once
Mahesh and I have agreed on the exact behavior here.

Dan
