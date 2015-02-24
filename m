From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] rhashtable: require max_shift if grow_decision
 defined
Date: Tue, 24 Feb 2015 13:18:28 -0500 (EST)
Message-ID: <20150224.131828.1632037288300527014.davem@davemloft.net>
References: <1424794259-30241-1-git-send-email-johunt@akamai.com>
	<1424794259-30241-2-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: johunt@akamai.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1424794259-30241-2-git-send-email-johunt@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Hunt <johunt@akamai.com>
Date: Tue, 24 Feb 2015 11:10:57 -0500

> If an rhashtable user defines a grow_decision fn they must also define a
> max_shift parameter.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>

I've already said today that I think this whole indirection stuff
with grow and shrink decisions should simply go away.

Everyone defines it to the generic rhashtable routine, therefore
that should just be made private to lib/rhashtable.c, called
directly, and the methods completely removed.

Given that, this change makes no sense.

When a limit is not specified, we should unconditionally grow rather
than refuse to grow.  One should not be required to specify this at
all.  If you have no idea what limit might be reasonable, you specify
nothing at all and just let available memory be the limiting factor.


