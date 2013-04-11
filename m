From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 08:54:35 -0700
Message-ID: <1365695675.3887.165.camel@edumazet-glaptop>
References: <1365684023-9967-1-git-send-email-sebastian.hesselbarth@gmail.com>
	 <20130411131333.GD1910@1wt.eu>
	 <CABJ1b_TQDabT1J7ffo5cb1Th=71bcSduifMJaDpfVRiiHvtWDw@mail.gmail.com>
	 <20130411150326.GA19978@1wt.eu>
	 <CABJ1b_TRxm97DKJLP_h0VwMJvcYmSpjoJvtg1KvBNGah=VzqMQ@mail.gmail.com>
	 <20130411153256.GH1910@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>,
	Soeren Moch <smoch@web.de>, Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130411153256.GH1910@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-11 at 17:32 +0200, Willy Tarreau wrote:
> On Thu, Apr 11, 2013 at 05:27:03PM +0200, Sebastian Hesselbarth wrote:
> > I don't have a strong opinion on whether Soeren's or your proposal should
> > be submitted. But I insist on having one of them in, as GRO significantly
> > improves the common use case, is enabled by default, and not as
> > constrained as LRO.
> 
> I agree, use yours first, but we should keep an eye on this. Since you have
> everything to run a test, please try to see if you can get netperf to run
> over IPv6, I'm sure the NIC doesn't handle it.

Willy, testing the checksum in the NIC driver itself prevents the stack
doing GRO even if the NIC could not checksum the packet, as in GRE
tunneling for example.

So Sebastien patch is better IMHO : Just call the napi gro handler and
let core stack handles the details ;)
