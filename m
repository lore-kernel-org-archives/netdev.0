From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: add IPComp extension match support
Date: Thu, 5 Dec 2013 19:34:02 +0100
Message-ID: <20131205183402.GA8949@localhost>
References: <1385607204-27650-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385607204-27650-1-git-send-email-fan.du@windriver.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Nov 28, 2013 at 10:53:24AM +0800, Fan Du wrote:
> With this plugin, user could specify IPComp tagged with certain 
> CPI that host not interested will be DROPped or any other action.
> 
> For example:
> iptables -A INPUT -p 108 -m ipcomp --ipcompspi 0x87 -j DROP
> 
> Then input IPComp packet with CPI equates 0x87 will not reach
> upper layer anymore.

I think that, with a little bit more work, you can add support for
IPv6 as well. From RFC 3173:

"In the IPv6 context, IPComp is viewed as an end-to-end payload, and
MUST NOT apply to hop-by-hop, routing, and fragmentation extension
headers.

You can perform that IPv6-specific handling to skip these extension
headers and reach the IPComp header by means of the ipv6_find_hdr()
helper function.

BTW, please post the iptables userspace part as well.
