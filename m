From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Sat, 05 Nov 2005 19:32:46 +0900 (JST)
Message-ID: <200511051032.jA5AWlqC005713@toshiba.co.jp>
References: <436C7937.9070901@trash.net>
	<20051105093821.GA30966@gondor.apana.org.au>
	<436C81AD.7070308@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <436C81AD.7070308@trash.net>
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


Hi, Patrick,

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 05 Nov 2005 10:55:57 +0100

> > Also, I thought Yoshifuji-san's objection is not just about
> > transport mode packets passing through netif_rx twice, but
> > passing through netfilter twice as well?
> 
> I think so, but he didn't mention a reason why he objects to it.
> I also don't think it can be done otherwise while still keeping
> netfilter "just working" for all cases, which IMO is highly
> desirable.

I try to comment based on discussion with Yoshifuji-san and Miyazawa-san.

We think it's confusing for user to mix decrypted packets and pre-decrypted
ones to same hook. For example, if user want to accept packets encrypted by
transport mode ESP and drop others, he will do "iptables -A INPUT -p esp -j
ACCEPT" and "iptables -P INPUT DROP". But decrypted packets will be dropped
because of the 2nd command. Of cause the match module 'policy' will be helpful
in such case, but it's simple if he can different name of hook with INPUT.

And, in logical, the hook for decrypted packet and the one for pre-decrypted
packet is different like the current LOCAL_IN and LOCAL_OUT. Their place and
the packets they can see, are different.

This can be said about output path. The hook for encrypted packet and the one
for pre-encrypted packet is different.

In the current, LOCAL_OUT see pre-encrypted packet. I've been assuming
that LOCAL_OUT see the packets just before sending them from network device.
This is the reason why I said "I support the way" - which means LOCAL_OUT
doesn't see pre-encrypted packet.

Meanwhile the hook to see pre-encrypted packet is necessary for NAT
indeed as you pointed out. Then our suggestion is adding new hook
with new name, and distinguishing cleary between the usage of new and
current hook.

BTW, tunnel mode is special case. We can avoid confusing by operation
and so on. For example, using different address for inner and outer header.
We agree to call netif_rx() twice for tunneled packets, as ever.

Regards,

-- Yasuyuki Kozakai
