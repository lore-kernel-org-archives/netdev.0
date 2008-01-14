From: Patrick McHardy <kaber@trash.net>
Subject: Re: sparc oops in ip_fast_csum
Date: Mon, 14 Jan 2008 07:09:22 +0100
Message-ID: <478AFC92.50508@trash.net>
References: <20080105094400.GH27894@ZenIV.linux.org.uk> <E1JBJHA-0000hy-00@gondolin.me.apana.org.au> <20080106020214.GQ27894@ZenIV.linux.org.uk> <20080106041430.GA3784@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, m.kozlowski@tuxland.pl,
	davem@davemloft.net, sparclinux@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753938AbYANGOu@vger.kernel.org>
In-Reply-To: <20080106041430.GA3784@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Patrick, please have a look at the former.  In fact it's not just
> that ihl may be bogus (which might be harmless as long as the REJECT
> hook only gets called from within the IP stack), I think REJECT would
> also do the wrong thing if the packet had IP options.  So perhaps we
> should just make it create a packet from scratch rather than being
> too clever in reusing the old one.


We currently silently drop packets with IP options in the reject
target. The length check should be fine since its only called
through the IP stack or bridge netfilter, which replicates the
IP stack checks.

But I agree to your suggestion, that will allow us to properly
handle packets with IP options. I'll take care of this.
