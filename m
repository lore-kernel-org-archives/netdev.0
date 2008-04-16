From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 16 Apr 2008 08:40:25 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABC73@nt-irva-0751.brcm.ad.broadcom.com>
References: <20080415.203108.55491723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>, tonyb@cybernetics.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933147AbYDPPlL@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080415.203108.55491723.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> Matt, skb->mac_header is either a pointer or an integer offset
> depending upon whether we are building 32-bit or 64-bit.
> 
> Testing skb->mac_header is therefore wrong, because it's an
> offset from a pointer in the 64-bit case and therefore it's
> alignment does not indicate correctly the actual final alignment
> of skb->head + skb->max_header.
> 
> Therefore you should test skb_mac_header(skb) and cast it with
> (unsigned long).

Isn't it better to test for skb->data?  That's where we tell
the hardware to start transmitting.

> 
> Please respin this fix with that correction so I can apply it
> and get this bug fixed, thanks!
> 
> 

We think that this problem is unique in Tony's environment because
of the PCIE-to-PCI bridge that he is using.  We therefore want to
test for that bridge and apply the workaround only when it's present.
We've never seen this problem in the last 6 or 7 years during the
lifetime of the 5701.

We'll try to get this done ASAP.

Thanks.
