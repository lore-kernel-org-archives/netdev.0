From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 09:10:44 -0700
Message-ID: <1365696644.3887.172.camel@edumazet-glaptop>
References: <1365684023-9967-1-git-send-email-sebastian.hesselbarth@gmail.com>
	 <20130411131333.GD1910@1wt.eu>
	 <CABJ1b_TQDabT1J7ffo5cb1Th=71bcSduifMJaDpfVRiiHvtWDw@mail.gmail.com>
	 <20130411150326.GA19978@1wt.eu>
	 <CABJ1b_TRxm97DKJLP_h0VwMJvcYmSpjoJvtg1KvBNGah=VzqMQ@mail.gmail.com>
	 <20130411153256.GH1910@1wt.eu> <1365695675.3887.165.camel@edumazet-glaptop>
	 <20130411160258.GI1910@1wt.eu>
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
In-Reply-To: <20130411160258.GI1910@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-11 at 18:02 +0200, Willy Tarreau wrote:

> OK, that makes sense indeed, I didn't think about this case. All
> I remember was that the old call achieved a higher packet rate
> than napi_gro_receive, but it was on an older kernel and I can't
> be more specifics after several months :-/

Its probably true that the GRO handler consumes more cpu for packets
that cant be aggregated in the end.

Thats a trade off, and maybe we could add in the core stack a device
feature to instruct gro handler to do a short cut for packets with no
checksum. Or better a sysctl so that a static_branch can be used.
