From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Mon, 13 Nov 2006 17:44:12 -0800
Message-ID: <OF31924028.FDB731A2-ON88257226.0006F081-88257226.00098A71@us.ibm.com>
References: <20061113.165058.15265737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: brian.haley@hp.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:57765 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1752375AbWKNBoT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 20:44:19 -0500
In-Reply-To: <20061113.165058.15265737.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote on 11/13/2006 04:50:58 PM:
 
> Puzzling :-)  Then why is the transformation only performed for
> UDP in the ipv4 stack?  It seems by your logic TCP would need
> to either do the "if (sum==0) sum=~0;"  thing or it would need
> to accept both "0" and "~0" in the checksum checking path.

        That's actually what I was suggesting. In 1's-complement,
~0 == -0 which is still 0, so barring any special case (like UDP's
"0 means no checksum" rule), it should be equally valid for a
packet to have 0 or ~0 as the checksum (with otherwise identical
data)-- they are both correct, and equal to each other. That
extra 1's-complement 0 is, of course, why UDP can have the
special case of remapping 0->~0.
        Since the patch was for output-side, it doesn't matter
whether you remap 0 to ~0 or not (except for the special case),
but a receiver technically should allow either.
        In practice, it won't matter if the machines you're talking
to are remapping (or not) in the same way. But 0 and -0 (aka ~0)
are still equal. :-)
        It obviously doesn't come up much.

                                                        +-DLS

