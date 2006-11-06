From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [DECNET] Endian bug fixes
Date: Mon, 6 Nov 2006 10:32:43 +0000
Message-ID: <20061106103243.GF29920@ftp.linux.org.uk>
References: <1162809062.27980.311.camel@quoit.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Caulfield <patrick@tykepenguin.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:18107 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1753086AbWKFKcs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 05:32:48 -0500
To: Steven Whitehouse <swhiteho@redhat.com>
Content-Disposition: inline
In-Reply-To: <1162809062.27980.311.camel@quoit.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 06, 2006 at 10:31:02AM +0000, Steven Whitehouse wrote:
> +	opt->opt_optl   = dn_htons((__u16)*ptr++);

Lose that cast; it's only confusing the things...

> +	memcpy(opt->opt_data, ptr, dn_ntohs(opt->opt_optl));
> +	skb_pull(skb, dn_ntohs(opt->opt_optl) + 1);

... and I'd actually do

	u16 len = *ptr++; /* yes, it's 8bit on the wire */
	opt->opt_optl   = dn_htons(len);
	BUG_ON(len > 16); /* we've checked the contents earlier */
	memcpy(opt->opt_data, ptr, len);
	skb_pull(skb, len + 1);
