From: Derek Fawcus <dfawcus@cisco.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Wed, 9 Oct 2002 17:00:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021009170018.H29133@edinburgh.cisco.com>
References: <20021008.000559.17528416.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021008.000559.17528416.yoshfuji@linux-ipv6.org>; from yoshfuji@linux-ipv6.org on Tue, Oct 08, 2002 at 12:05:59AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 08, 2002 at 12:05:59AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> Hi,
> 
> Prefix length for link-local address should be 64, not 10.
> This patch fixes prefix length of link-local address.
> 
> Following patch is against 2.4.19.

Huh?

Without reading the kernel routing table code a bit more,  I'm not certain
what that change does,  but it looks as if it might be changing the
connected route for a link local from fe80::/10 to fe80::/64.

I'd actually say that is wrong.

All link local's are currently supposed to have those top bits
('tween 10 and 64) zero'd,  however any address within the link local
prefix _is_ on link / connected and should go to the interface.

i.e. it's perfectly valid for me to assign a link local of fe80:1910::10
     to an interface and expect it to be work,  likewise for a packet
     destined to any link local address to trigger ND.

DF
