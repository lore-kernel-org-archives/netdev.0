From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Wed, 25 Aug 2010 16:10:58 +0400
Message-ID: <20100825121058.GA28498@ms2.inr.ac.ru>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca> <20100823080543.319143e3@nehalam> <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca> <1282672647.2302.15.camel@achroite.uk.solarflarecom.com> <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca> <1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510> <1282715698.2467.681.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Marc Aurele La France <tsi@ualberta.ca>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1282715698.2467.681.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> It is, but ip_append_data() is allocating a huge head if MTU is huge.

Hmm, strange, as I remember, it was supposed to work right.

If the device supports SG (which is required to accept non-linear skbs anyway),
then ip_append_* should allocate skbs not rounded up to mtu and we should
allocate small skb with NFS header only. Does not it work?

I can only guess one possible trap: people could do _one_ huge ip_append_data()
(instead of "planned" scenario, when the header is sent with ip_append_data()
and the following payload is appended with ip_append_page()). Huge ip_append_data()
will generate huge skb indeed. Is this the problem?


BTW this issue could be revisited and this "will generate huge" can be reconsidered.
Automatic generation of fragmented skbs was deliberately suppressed, because it was
found that all devices existing at the moment when this code was written
are strongly biased against SG. Current code tries to _avoid_ generating
non-linear skbs, unless it is intended for zero-copy, which compensated
bias against SG. Modern hardware should work better.

Alexey
