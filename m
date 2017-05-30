From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/7] net: dsa: factor skb freeing on xmit
Date: Tue, 30 May 2017 17:37:08 +0200
Message-ID: <20170530153708.GI22758@lunn.ch>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
 <20170530142131.23568-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170530142131.23568-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:21:31AM -0400, Vivien Didelot wrote:
> The taggers are currently responsible to free the original SKB if they
> made a copy of it, or in case of error.
> 
> This patch simplifies this by freeing the original SKB in the
> dsa_slave_xmit caller if it differs from the return SKB (copy or NULL.)

So we have two different things here:

1) The tagger needs to drop the frame, because there is an error of
some sort.

2) The tagger allocates a new skb for the frame.

I think on error, the core code can drop the frame.

If the tagger allocates a new skb, i think the tagger should be
responsible for freeing to original.

	    Andrew
