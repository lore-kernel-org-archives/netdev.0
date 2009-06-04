From: Patrick McHardy <kaber@trash.net>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Thu, 04 Jun 2009 14:11:24 +0200
Message-ID: <4A27B9EC.2010301@trash.net>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090604113723.GA13018@ioremap.net> <4A27B5A1.9050300@trash.net> <20090604120719.GA14981@ioremap.net>
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
In-Reply-To: <20090604120719.GA14981@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Jun 04, 2009 at 01:53:05PM +0200, Patrick McHardy (kaber@trash.net) wrote:
>>> That's hard - there is no hook number in the match function, so we do
>>> not really know if it is forward, input or prerouting.
>> This is really needed, spamming the ring buffer is not a good option.
>>
>> I'd say just add the hook number to xt_match_param. Its a bit
>> inconsistent anyways that we're handing it to checkentry for
>> validation, but not to the match function.
> 
> Doesn't checkentry receive a mask of all possible hooks? There is still
> no per-packet hook number. Although we can always use INPUT hook since
> its the most widely used one. And drop a comment about this abuse.

Thats not what I meant. struct xt_match_param is passed to the
->match() callbacks from *t_do_table(). This is where you can
add the real hook number to have it available in ->match().

(Forgot to mention earlier: please in a seperate patch and adjusting
  all *tables copies)
