From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH v2] bridge: make it possible for packets to
 traverse the bridge without hitting netfilter
Date: Mon, 23 Feb 2015 17:06:19 +0100
Message-ID: <20150223160619.GF24297@breakpoint.cc>
References: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Palik, Imre" <imrep@amazon.de>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, fw@strlen.de,
	linux-kernel@vger.kernel.org, Anthony Liguori <aliguori@amazon.com>,
	"David S. Miller" <davem@davemloft.net>
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Imre Palik <imrep.amz@gmail.com> wrote:
> The netfilter code is made with flexibility instead of performance in mind.
> So when all we want is to pass packets between different interfaces, the
> performance penalty of hitting netfilter code can be considerable, even when
> all the firewalling is disabled for the bridge.
> 
> This change makes it possible to disable netfilter on a per bridge basis.
> In the case interesting to us, this can lead to more than 15% speedup
> compared to the case when only bridge-iptables is disabled.

I wonder what the speed difference is between no-rules (i.e., we hit jump label
in NF_HOOK), one single (ebtables) accept-all rule, and this patch, for
the call_nf==false case.

I guess your 15% speedup figure is coming from ebtables' O(n) rule
evaluation overhead?  If yes, how many rules are we talking about?

Iff thats true, then the 'better' (I know, it won't help you) solution
would be to use nftables bridgeport-based verdict maps...

If thats still too much overhead, then we clearly need to do *something*...

Thanks,
Florian
