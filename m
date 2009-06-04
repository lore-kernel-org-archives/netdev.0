From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Thu, 4 Jun 2009 15:30:28 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906041526540.10684@fbirervta.pbzchgretzou.qr>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090604113723.GA13018@ioremap.net> <4A27B5A1.9050300@trash.net> <20090604120719.GA14981@ioremap.net> <4A27B9EC.2010301@trash.net> <20090604131153.GA18251@ioremap.net>
 <4A27C921.6020301@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A27C921.6020301@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2009-06-04 15:16, Patrick McHardy wrote:
> Evgeniy Polyakov wrote:
>> On Thu, Jun 04, 2009 at 02:11:24PM +0200, Patrick McHardy (kaber@trash.net)
>> wrote:
>>> Thats not what I meant. struct xt_match_param is passed to the
>>> ->match() callbacks from *t_do_table(). This is where you can
>>> add the real hook number to have it available in ->match().
>>>
>>> (Forgot to mention earlier: please in a seperate patch and adjusting
>>> all *tables copies)
>>
>> Kind of this (for ipv4 only so far, also reorderd a field to fill the
>> gap):
>
> Exactly. But please verify that by reordering, you're not moving
> the more commonly used members out of the first cacheline.
>
I am not sure the struct was ordered for optimized cacheline performance
beforehand either.

* par->in, par->out is only rarely used (think of xt_physdev, besides
  ipt_do_table itself);
* par->match similarly (xt_hashlimit)
* par->matchinfo, though showing more grep results, is usually copied to
  the stack by means of struct foo_target_info *info = par->matchinfo;
etc.
