From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Tue, 31 May 2005 15:05:38 -0700 (PDT)
Message-ID: <20050531.150538.39158461.davem@davemloft.net>
References: <1117281581.6251.68.camel@localhost.localdomain>
	<20050528123542.GR15391@postel.suug.ch>
	<42986A85.9060001@eurodev.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pablo@eurodev.net
In-Reply-To: <42986A85.9060001@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Pablo Neira <pablo@eurodev.net>
Date: Sat, 28 May 2005 14:56:37 +0200

> Netfilter used to follow this approach in early 2.6 kernels and Patrick 
> McHardy demostrated with some oprofile stuff that skb_copy_bits 
> decreased performance.

This case got converted into what skb_copy_bits() was probably
meant to be, skb_header_pointer().

The idea is, if it's linear in the SKB already (headers almost
certainly are) just pass back the pointer to it, else copy into
the user provided temporary buffer and return a pointer to that.

The text search stuff could easily do the same thing, using
a 32-byte or so sliding window to run the text search on.
