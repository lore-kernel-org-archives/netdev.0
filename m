From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFT] nf_contrack_udp: handle packets with padding and
 hwchecksum
Date: Tue, 21 Feb 2012 13:19:11 +0100
Message-ID: <20120221121911.GA25258@1984>
References: <20120130155816.GA1400@phenom.dumpdata.com>
 <20120130083843.160ffe5e@nehalam.linuxnetplumber.net>
 <1327944148.3303.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120217101648.01f31fcd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120217101648.01f31fcd@nehalam.linuxnetplumber.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Fri, Feb 17, 2012 at 10:16:48AM -0800, Stephen Hemminger wrote:
> If UDP packet with extra padding is received on a device that
> does hardware checksumming (but not checking) is processed
> by netfilter conntrack, it would generate a bogus warning
> about the checksum being incorrect.
> 
> There were two possible solutions. The netfilter conntrack
> code could trim the packet, discarding the extra padding
> and adjusting the checksum. Or it can force regular
> non-offloaded checksum. This patch implements the latter
> on the principal that is better for firewall code to not
> modify the packet.

I like this approach.

> Compile tested only; haven't been able to reproduce the
> problem yet.

Let me know if I should pass this to davem once you confirm this fixes
the problem you're noticing.
