From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in absence of MSS option
Date: Tue, 11 Jun 2013 09:43:07 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org> <1370880461-4265-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1370880461-4265-4-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The clamp-mss-to-pmtu option of the xt_TCPMSS target can cause issues
> connecting to websites if there was no MSS option present in the
> original SYN packet from the client. In these cases, it may add a
> MSS higher than the default specified in RFC879. Fix this by never
> setting a value > 536 if no MSS option was specified by the client.
> 
> This closes netfilter's bugzilla #662.
...
> +	/* RFC 879 states that the default MSS is 536 without specific
> +	 * knowledge that the destination host is prepared to accept larger.
> +	 * Since no MSS was provided, we MUST NOT set a value > 536.
> +	 */
> +	newmss = min(newmss, (u16)536);
> +

Is setting the mss to 536 actually ever sensible?
RFC 879 might say that it is the default (and the minimum
that must be supported), but in practise the actual mss
is very likely to be only slightly shorter than the standard
ethernet mss.
Although strict conformance with RFC 879 might require the mss
be clamped to 536, pragmatically a value much nearer 1400 would
make sense - systems with very low mtu/mss are probably likely
to advertise it.

	David



