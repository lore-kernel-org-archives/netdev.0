From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC, PATCH 3/5]: netfilter+ipsec - input hooks
Date: Thu, 18 Mar 2004 22:15:23 -0800
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040318221523.07298f03.davem@redhat.com>
References: <20040308110331.GA20719@gondor.apana.org.au>
	<404C874D.4000907@trash.net>
	<20040308115858.75cdddca.davem@redhat.com>
	<4059CF0E.3050708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4059CF0E.3050708@trash.net>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 17:32:14 +0100
Patrick McHardy <kaber@trash.net> wrote:

> If the protocol handler of a packet with a secpath
> pointer is a non-xfrm-protocol the packet was handled by ipsec and
> is done now, it traverses the PRE_ROUTING and LOCAL_IN hooks then.
> This catches packets from both tunnel-mode and transport-mode SAs.

Be careful!  xfrm4_tunnel handles both uncompressed ipcomp packets
_and_ IPIP encapsulator device packets.  Yet you will intepret usage
of the ipprot as 'xfrm_prot==1' in all cases.

Yes this is ugly... if we added some kind of flag bit-mask to sk_buff,
would that allow an easier implementation?
