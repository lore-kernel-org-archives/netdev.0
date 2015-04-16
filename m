From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Thu, 16 Apr 2015 11:20:52 +0200
Message-ID: <552F7EF4.9030107@iogearbox.net>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>	 <552E9E8D.1080000@eu.citrix.com>	 <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>	 <552EA2BC.5000707@eu.citrix.com>	 <1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com>	 <552EA844.5010308@eu.citrix.com> <1429121979.7346.138.camel@edumazet-glaptop2.roam.corp.google.com> <552F7936.9070205
 @eu.citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	linux-arm-kernel@lists.infradead.org,
	David Vrabel <david.vrabel@citrix.com>
To: George Dunlap <george.dunlap@eu.citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38908 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756682AbbDPJU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 05:20:59 -0400
In-Reply-To: <552F7936.9070205@eu.citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2015 10:56 AM, George Dunlap wrote:
> On 04/15/2015 07:19 PM, Eric Dumazet wrote:
>> On Wed, 2015-04-15 at 19:04 +0100, George Dunlap wrote:
>>
>>> Maybe you should stop wasting all of our time and just tell us what
>>> you're thinking.
>>
>> I think you make me wasting my time.
>>
>> I already gave all the hints in prior discussions.
>
> Right, and I suggested these two options:

So mid term, it would be much more beneficial if you attempt fix the
underlying driver issues that actually cause high tx completion delays,
instead of reintroducing bufferbloat. So that we all can move forward
and not backwards in time.

> "Obviously one solution would be to allow the drivers themselves to set
> the tcp_limit_output_bytes, but that seems like a maintenance
> nightmare.

Possible, but very hacky, as you penalize globally.

> "Another simple solution would be to allow drivers to indicate whether
> they have a high transmit latency, and have the kernel use a higher
> value by default when that's the case." [1]
>
> Neither of which you commented on.  Instead you pointed me to a comment

What Eric described to you was that you introduce a new netdev member
like netdev->needs_bufferbloat, set that indication from driver site,
and cache that in the socket that binds to it, so you can adjust the
test in tcp_xmit_size_goal(). It should merely be seen as a hint/indication
for such devices. Hmm?

> that only partially described what the limitations were. (I.e., it
> described the "two packets or 1ms", but not how they related, nor how
> they related to the "max of 2 64k packets outstanding" of the default
> tcp_limit_output_bytes setting.)
>
>   -George
>
> [1]
> http://marc.info/?i=<CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
