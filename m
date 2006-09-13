From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP Pacing
Date: Wed, 13 Sep 2006 12:41:52 +0900
Message-ID: <20060913124152.350cd9b2@localhost.localdomain>
References: <200609121958.22820.root@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Carlo Caini <ccaini@deis.unibo.it>,
	Rosario Firrincieli <rfirrincieli@arces.unibo.it>,
	Giovanni Pau <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53940 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751524AbWIMDmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 23:42:18 -0400
To: root@danielinux.net
In-Reply-To: <200609121958.22820.root@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Sep 2006 19:58:21 +0200
Daniele Lacamera <root@danielinux.net> wrote:

> Hello,
> 
> Please let me insist once again on the importance of adding a TCP Pacing 
> mechanism in our TCP, as many people are including this algorithm in 
> their congestion control proposals. Recent researches have found out 
> that it really can help improving performance in different scenarios, 
> like satellites and long-delay high-speed channels (>100ms RTT, Gbit). 
> Hybla module itself is cripple without this feature in its natural 
> scenario. 
> 
> The following patch is totally non-invasive: it has a config option and 
> a sysctl switch, both turned off by default. When the config option is 
> enabled, it adds only 6B to the tcp_sock.

Yes, but tcp_sock is already greater than 1024 on 64 bit, and needs
a diet.

> 
> Signed-off by: Daniele Lacamera <root@danielinux.net>

Pacing in itself isn't a bad idea, but:
  * Code needs to follow standard whitespace rules
 	- blanks around operators		
	- blank after keyword
	- Avoid (needless) paraenthesis
Bad:
       if( (state==TCP_CA_Recovery) &&(tp->snd_cwnd <
tp->snd_ssthresh))
		window=(tp->snd_ssthresh)<<3;
Good:
	if (state == TCP_CA_Recovery && tp->snd_cwnd < tp->snd_ssthresh)
		window = tp->snd_ssthresh << 3;

  * Since it is most useful over long delay links, maybe it should
    be a route parameter.

