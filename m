From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3 resend] netfilter: nf_conntrack_sip: Handle Cisco 7941/7945
 IP phones
Date: Thu, 26 May 2011 18:50:58 +0200
Message-ID: <4DDE84F2.7080706@netfilter.org>
References: <bc781b295b38241533a2d90c1aea15b3@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kevin Cernekee <cernekee@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <bc781b295b38241533a2d90c1aea15b3@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On 20/05/11 06:36, Kevin Cernekee wrote:
> Most SIP devices use a source port of 5060/udp on SIP requests, so the
> response automatically comes back to port 5060:
> 
> phone_ip:5060 -> proxy_ip:5060   REGISTER
> proxy_ip:5060 -> phone_ip:5060   100 Trying
> 
> The newer Cisco IP phones, however, use a randomly chosen high source
> port for the SIP request but expect the response on port 5060:
> 
> phone_ip:49173 -> proxy_ip:5060  REGISTER
> proxy_ip:5060 -> phone_ip:5060   100 Trying
> 
> Standard Linux NAT, with or without nf_nat_sip, will send the reply back
> to port 49173, not 5060:
> 
> phone_ip:49173 -> proxy_ip:5060  REGISTER
> proxy_ip:5060 -> phone_ip:49173  100 Trying
> 
> But the phone is not listening on 49173, so it will never see the reply.
> 
> This patch modifies nf_*_sip to work around this quirk by extracting
> the SIP response port from the Via: header, iff the source IP in the
> packet header matches the source IP in the SIP request.
> 
> Signed-off-by: Kevin Cernekee <cernekee@gmail.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>

@Eric: could you please confirm that you ack'ed this patch? I don't find
the email with your explicit ack.
