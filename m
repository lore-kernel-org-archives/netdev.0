From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 09 Jun 2014 08:04:19 -0700
Message-ID: <1402326259.3645.374.camel@edumazet-glaptop2.roam.corp.google.com>
References: <539319F6.2090907@cogentembedded.com>
	 <1402151680-11434-1-git-send-email-per.hurtig@kau.se>
	 <1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
	 <539413BA.7060903@kau.se>
	 <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
	 <5395B2FC.3070205@kau.se>
	 <1402324388.3645.359.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5395C7E9.4050406@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Anna =?ISO-8859-1?Q?Brunstr=F6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:63290 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933254AbaFIPEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 11:04:21 -0400
Received: by mail-pb0-f51.google.com with SMTP id ma3so5037170pbc.10
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 08:04:21 -0700 (PDT)
In-Reply-To: <5395C7E9.4050406@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 16:42 +0200, Per Hurtig wrote:
> Tried to run the script, but I don't have the "common/defaults" and the 
> test scripts from the git repository fails on all TCP tests for Linux. 
> The results I listed in the enclosed packet traces are from two real 
> machines communicating with each other (with fresh net-next kernels and 
> TLP without the zero probe check), so I tend to rely more on those 
> results.

Do not top post on netdev.

We at Google run about 1000 packet drill tests for any functional change
in TCP stack. This is the only way we can scale.

We are not 'studying by hand' various tcpdumps when a tool can do it
properly.

Nandita asked you give a pointer to the source code explaining how fast
retransmit was done for this specific case, but you provided a tcpdump,
which hardly can be reproduced and be the answer to the question.

So now, we are trying to have a test to reproduce the issue and check
the fix is complete.

So far, I am not really convinced. It seems the FIN _is_ retransmitted,
but I do not see the SACK for this RTX is properly handled in time.

Its one thing checking the FIN is retransmitted, its another to check
that the SACK will trigger sensible behavior.

If you carefully check your tcpdump, you'll see there is the same
problem, and you missed it, while packetdrill exactly pointed it.

Thanks
