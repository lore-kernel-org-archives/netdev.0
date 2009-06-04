From: Patrick McHardy <kaber@trash.net>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Thu, 04 Jun 2009 13:53:05 +0200
Message-ID: <4A27B5A1.9050300@trash.net>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090604113723.GA13018@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090604113723.GA13018@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hi.
> 
> On Wed, May 27, 2009 at 06:28:16PM +0200, Patrick McHardy (kaber@trash.net) wrote:
>>> You will find something like this in the syslog:
>>> Windows [2000:SP3:Windows XP Pro SP1, 2000 SP3]: 11.22.33.55:4024 -> 
>>> 11.22.33.44:139 hops=4
>>> Linux [2.5:]: 1.2.3.4:44448 -> 11.22.33.44:22 hops=4
>> Please convert this to use nf_log_packet().
> 
> That's hard - there is no hook number in the match function, so we do
> not really know if it is forward, input or prerouting.

This is really needed, spamming the ring buffer is not a good option.

I'd say just add the hook number to xt_match_param. Its a bit
inconsistent anyways that we're handing it to checkentry for
validation, but not to the match function.
