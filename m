From: "Zhouyi Zhou" <yizhouzhou@ict.ac.cn>
Subject: Re: Re: [PATCH V2] netfilter: h323: avoid potential attack
Date: Thu, 28 Jan 2016 23:13:34 +0800 (GMT+08:00)
Message-ID: <5b6c32.5bd1.15288cbf662.Coremail.yizhouzhou@ict.ac.cn>
References: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
 <20160128142959.GB30994@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Zhouyi Zhou" <zhouzhouyi@gmail.com>, eric.dumazet@gmail.com,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Florian Westphal" <fw@strlen.de>, gnomes@lxorguk.ukuu.org.uk,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160128142959.GB30994@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your advices.
I will take your advice if I could have the opportunity
to write the final code.

As matter of factor, I trigger this bug when I tried to 
migrate H323 code to other operating systems.

This could trigger a panic because get_h2x5_addr functions
is the first time we ever try to ask for potentially
out of range data because of H323 style decodings 
(the value taddr->ipAddress.ip is decoded in the midway between
calling skb_header_pointer and calling get_h2x5_addr)



> -----Original Messages-----
> From: "Florian Westphal" <fw@strlen.de>
> Sent Time: Thursday, January 28, 2016
> To: "Zhouyi Zhou" <zhouzhouyi@gmail.com>
> Cc: eric.dumazet@gmail.com, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.or, "Zhouyi Zhou" <yizhouzhou@ict.ac.cn>
> Subject: Re: [PATCH V2] netfilter: h323: avoid potential attack
> 
> Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> > Thanks Eric for your review and advice.
> > 
> > I think hackers chould build a malicious h323 packet to overflow
> > the pointer p which will panic during the memcpy(addr, p, len)
> > 
> > For example, he may fabricate a very large taddr->ipAddress.ip;
> 
> Can you be more specific?
> 
> h323_buffer is backend storage for skb_header_pointer, i.e.
> this will error out early when we ask for more data than is available in
> packet.
> 
> I don't understand how this could overflow anything.
> Even assuming 64k packet we'd still have enough room in h323_buffer
> for an ipv6 address, no? (we skip the l3/l4 header when extracting
> packet payload).
> 
