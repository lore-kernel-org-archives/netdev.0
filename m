From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Thu, 30 May 2013 17:55:59 +0200
Message-ID: <20130530175559.7cbb6851@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
	<1369842724.5109.44.camel@edumazet-glaptop>
	<20130530095117.503eeee7@redhat.com>
	<1369924750.5109.91.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757745Ab3E3P42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 11:56:28 -0400
In-Reply-To: <1369924750.5109.91.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 May 2013 07:39:10 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2013-05-30 at 09:51 +0200, Jesper Dangaard Brouer wrote:
> > On Wed, 29 May 2013 08:52:04 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > > I am not sure it will solve the ATM logic (with the 5 bytes
> > > overhead per 48 bytes cell)
> > 
> > Are you talking about, that for GSO frames we are not adding a encap
> > overhead to each "sub" skb.
> 
> This part is now done properly in qdisc_pkt_len_init() since linux-3.9

Thanks for the pointer, but qdisc_pkt_len_init() only adds the
EthMAC+IP+TCP header size for each GSO segment (stored in
qdisc_skb_cb(skb)->pkt_len).
It is still missing the AAL5 encapsulation overhead per GSO segment.

Besides I can see that __qdisc_calculate_pkt_len() "forgets" this
information and overwrites qdisc_skb_cb(skb)->pkt_len (iif a stab is
defined on the qdisc).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
