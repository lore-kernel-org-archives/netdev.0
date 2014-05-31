From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Sat, 31 May 2014 15:43:16 +0930
Message-ID: <538972FC.2090801@davidnewall.com>
References: <53815623.8020506@davidnewall.com>	<20140529.153424.1310751217059624351.davem@davemloft.net>	<53884CC6.2000000@davidnewall.com> <20140530.174608.587404162482133282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, fw@strlen.de, stephen@networkplumber.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org, bsd@redhat.com,
	vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140530.174608.587404162482133282.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/05/14 10:16, David Miller wrote:
> I don't see why you don't simply keep br_parse_ip_options() around
> and adjust it as you need, you're just mostly duplicating it's
> contents into br_nf_pre_routing().

More accurately, I'm *restoring* br_parse_ip_options()'s contents to 
br_nf_pre_routing().  The reasons why are twofold: I'm undoing a change 
which turns out to have been a mistake; and leaving it largely as-is, 
just removing the call to ip_options_compile(), would be confusing in 
that the name (br_pase_ip_options()) gives an expectation of function 
that would be untrue.

I can see an argument in favour of leaving br_parse_options() around, 
being that it is called from three places, and thus restoring the code 
removes checks which are currently being performed.  They weren't being 
performed before and it's not clear that they are needed, but if you say 
that it would be better, I'll leave it around and just remove the call 
to ip_options_compile(). Just say the word.
