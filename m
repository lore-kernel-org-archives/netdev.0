From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Sat, 05 Nov 2005 09:58:24 +0100
Message-ID: <436C7430.5030707@trash.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<20051027121545.GA5530@gondor.apana.org.au>
	<20051027.235732.01166239.yoshfuji@linux-ipv6.org>
	<20051105063030.GA32385@gondor.apana.org.au>
	<436C6580.6030007@trash.net>
	<20051105083955.GA30293@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051105083955.GA30293@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sat, Nov 05, 2005 at 08:55:44AM +0100, Patrick McHardy wrote:
> 
>>>OK.  Would it be workable for you if LOCAL_IN only saw the decrypted
>>>packets without ever seeing the encrypted ones?
>>
>>How exactly would that work? I guess we couldn't do NAT with
>>the encrypted packet anymore?
> 
> I'm presuming that Yoshifuji-san has no objections to applying the
> NAT-related hooks twice on IPsec since IPv6 does/will not have NAT.
> 
> Given that assumption, we should be able to separate the existing
> LOCAL_IN into a read-only (filtering) part and a read-write part.
> The latter would be applied unconditionally while the former can
> be skipped.

So far I don't see why we shouldn't just the LOCAL_IN hook as it
is and also haven't heard any reason against it. I'm fine with
not using netif_rx, but I don't see why we should complicate
things by introducing special semantics for decapsulated transport
mode packets.

>>I would prefer something similar to the second set of patches.
>>Instead of calling netif_rx we could use NF_HOOK and simulate
>>the relevant parts of the input path for IPv4 and NAT. This
>>would assure that statistics are still correct and tcpdump is
>>not affected, which were Yoshifuji's biggest concerns if I
>>understood correctly.
> 
> I don't think netif_rx is the problem here.  The question is
> how and where do we place the netfilter hooks.  Even without
> netif_rx the same problem is going to be there.

IMO the view for netfilter should be as if we called netif_rx,
so on the input path decapsulated packets from the innermost
transport mode SA should go through PRE_ROUTING->LOCAL_IN
or possibly FORWARD in case of NAT.
