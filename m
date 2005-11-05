From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Sat, 05 Nov 2005 08:55:44 +0100
Message-ID: <436C6580.6030007@trash.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<20051027121545.GA5530@gondor.apana.org.au>
	<20051027.235732.01166239.yoshfuji@linux-ipv6.org>
	<20051105063030.GA32385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051105063030.GA32385@gondor.apana.org.au>
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
> On Thu, Oct 27, 2005 at 11:57:32PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
>>Well, I really care.
>>I strongly believe that we SHOULD NOT mix encrypted
>>packets and plain text packets at the same hook.
>>e.g. LOCAL_IN is NOT for decrypted plain text packets,
>>but for the original encrypted ones.
> 
> 
> OK.  Would it be workable for you if LOCAL_IN only saw the decrypted
> packets without ever seeing the encrypted ones?

How exactly would that work? I guess we couldn't do NAT with
the encrypted packet anymore?

> I'd like to know where the boundaries are so we can find a compromise
> that works for everyone.

I would prefer something similar to the second set of patches.
Instead of calling netif_rx we could use NF_HOOK and simulate
the relevant parts of the input path for IPv4 and NAT. This
would assure that statistics are still correct and tcpdump is
not affected, which were Yoshifuji's biggest concerns if I
understood correctly.
