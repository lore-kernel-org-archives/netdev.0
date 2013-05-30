From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Thu, 30 May 2013 07:39:10 -0700
Message-ID: <1369924750.5109.91.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <1369842724.5109.44.camel@edumazet-glaptop>
	 <20130530095117.503eeee7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:55971 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932733Ab3E3OjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 10:39:13 -0400
Received: by mail-pb0-f41.google.com with SMTP id xb12so467845pbc.28
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 07:39:13 -0700 (PDT)
In-Reply-To: <20130530095117.503eeee7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-30 at 09:51 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 29 May 2013 08:52:04 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > I am not sure it will solve the ATM logic (with the 5 bytes overhead
> > per 48 bytes cell)
> 
> Are you talking about, that for GSO frames we are not adding a encap
> overhead to each "sub" skb.

This part is now done properly in qdisc_pkt_len_init() since linux-3.9


No I was really mentioning the DIV_ROUND_UP(pkt_len,48)*53 thing
