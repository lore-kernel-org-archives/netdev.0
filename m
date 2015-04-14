From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Tue, 14 Apr 2015 08:27:48 -0400
Message-ID: <552D07C4.1020509@mojatatu.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org> <20150410132205.GF23070@casper.infradead.org> <20150410200901.GB5968@salvia> <20150412.211421.1771298417488412635.davem@davemloft.net> <20150413201913.GD20275@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:32846 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbbDNM1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 08:27:52 -0400
Received: by iecrt8 with SMTP id rt8so469935iec.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 05:27:50 -0700 (PDT)
In-Reply-To: <20150413201913.GD20275@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/13/15 16:19, Patrick McHardy wrote:

> I'm going to jump in here since I think a good case for this can be
> made. It's going to be a bit longer, sorry. You can skip to the
> examples after the first three paragraphs since it's just a lot of
> TC bashing :)

Patrick, maybe i am misunderstanding.
Here I am arguing against Alexei for introducing a couple of
statements for the sake of performance and you want to put netfilter
on that code path and maybe move ingress to be dependent on netfilter
further up the stack? I know you are trying to sell the virtues
of nft but since you are busy bashing here, how about this polite
statement:
Netfilter is not known for its performance. Even with the ingress qlock
tc will outperform an equivalent operation done via netfilter.
Last i poked:
As the number of rules goes up, the performance difference goes up
significantly as well. When you mention the ingress qdisc lock
the analogy would be saying like saying "tc is overweight" when
infact netfilter is obese. tc can get better and there is effort
to get rid of the  lock (i am aware of efforts in that direction).
Having said that netfilter is more usable than tc - but that usability
is costly.

I like your example use case but I am not sure why you think those use
cases cant be trivially implemented with tc actions? I see a table
per cpu which is updated with info gleaned from arriving packets
as described by policy.
Maybe i am missing the connection.

In regards to ipt or conntrack; i am sure we could use your help
(and Pablo has been very nice to us) to make it a smoother experience.
We are trying not to replicate what you have done and therefore
reusing your code. OTOH, if i understood correctly you are talking
about replacing all these actions with ones you are going to write.
If you see issues we should fix them. Again, it would be preferable
if there are ways you can help make this even more seamless. And if
you decide you want to use something in tc we should make it smooth for
you.
But using conntrack or ipt or whatever new thing in the netfilter
code is optional for tc. Enforcing it by default is wrong. I also dont
believe in monopolies for classifiers. Sure nft is nice but i should
be able to use bpf if needed. It will make sense in some cases.
This is the design tc has. I know having a single approach as does
nft does reduce ui confusions - but even in your case a refresh is
needed (as in the introduction of nft). And i am sure that is not the
last time you'll do it. That experience transformation
is much smoother with tc when introducing a new classifier.

cheers,
jamal
