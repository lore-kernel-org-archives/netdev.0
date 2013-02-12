From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: team driver MAC NAT
Date: Tue, 12 Feb 2013 10:12:15 -0500
Message-ID: <511A5BCF.20907@mojatatu.com>
References: <20130212140247.GB18057@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bart.de.schuymer@pandora.be, stephen@networkplumber.org,
	pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130212140247.GB18057@minipsycho.orion>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri,

This would be a good fit for  a tc action. This way such a feature can be
used by other netdevs (including plain bridge, and not just team)
The main question is how does the tc action learn about the MAC
addresses that
it needs to convert.

cheers,
jamal

On 13-02-12 09:02 AM, Jiri Pirko wrote:
> Hi all.
> 
> I have following situation:
> 
> host X  .............  eth0 -> br0 <- team0 <- eth2  ..............  switch  .........  host Z
> host Y  .............  eth1 ---^         ^---- eth3  .................^
> 
> Now to achieve RX traffic balancing on team0, I have to mangle src mac of
> all outgoing packets. If the packet goes through eth2, src mac will be set to
> eth2 mac, same happens on eth3. I have to magle ARP packets as well.
> 
> This would achieve something which might be called "MAC NAT".
> 
> To unmangle RXed packets back to the original MAC adresses (of host X and host Y)
> I need to track "connections".
> 
> Now the question is: Should this be integrated in netfilter infrastructure?
> I'm thinking something similar to existing conntrack. NF_HOOK will be placed
> in team driver rx/tx functions (similar to what bridge does).
> 
> I think this would be nicer than to do it independently just in team driver code.
> Also this MAC NAT (with tracking connections, unlike what bridge MAC NAT does)
> can be probably handy for other purposes as well (not sure what)
> 
> Thanks for any suggestions.
> 
> Jiri
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

