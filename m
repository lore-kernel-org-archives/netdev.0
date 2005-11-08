From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Tue, 08 Nov 2005 15:01:43 +0100
Message-ID: <4370AFC7.2040701@trash.net>
References: <436C7937.9070901@trash.net>	<20051105093821.GA30966@gondor.apana.org.au>	<436C81AD.7070308@trash.net>
	<200511051032.jA5AWl2l000619@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200511051032.jA5AWl2l000619@toshiba.co.jp>
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

Yasuyuki KOZAKAI wrote:
> I try to comment based on discussion with Yoshifuji-san and Miyazawa-san.
> 
> We think it's confusing for user to mix decrypted packets and pre-decrypted
> ones to same hook. For example, if user want to accept packets encrypted by
> transport mode ESP and drop others, he will do "iptables -A INPUT -p esp -j
> ACCEPT" and "iptables -P INPUT DROP". But decrypted packets will be dropped
> because of the 2nd command. Of cause the match module 'policy' will be helpful
> in such case, but it's simple if he can different name of hook with INPUT.
> 
> And, in logical, the hook for decrypted packet and the one for pre-decrypted
> packet is different like the current LOCAL_IN and LOCAL_OUT. Their place and
> the packets they can see, are different.

I disagree. LOCAL_IN is for locally delivered packets, and both the
decrypted and the encrypted packet are delivered locally. This is
true for tunnel mode, handling transport mode the same way seem
consistent, not confusing to me. This is also the way klips has
done it for ages and users are used to this and are actually asking
for exactly this behaviour.

> This can be said about output path. The hook for encrypted packet and the one
> for pre-encrypted packet is different.

Well, this is not intended but one of the problems I want to fix.

> In the current, LOCAL_OUT see pre-encrypted packet. I've been assuming
> that LOCAL_OUT see the packets just before sending them from network device.
> This is the reason why I said "I support the way" - which means LOCAL_OUT
> doesn't see pre-encrypted packet.

Same holds here. LOCAL_OUT is for locally generated packets, and should
see both the plain text and the encrypted packet. This is entirely
consistent with other tunnels like IPIP or GRE.

> Meanwhile the hook to see pre-encrypted packet is necessary for NAT
> indeed as you pointed out. Then our suggestion is adding new hook
> with new name, and distinguishing cleary between the usage of new and
> current hook.

We can't do that because introducing new hooks to the tables breaks
userspace compatibility.

Regards
Patrick
