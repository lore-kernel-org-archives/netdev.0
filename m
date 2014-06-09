From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 09 Jun 2014 17:56:39 +0200
Message-ID: <5395D937.5060801@kau.se>
References: <539319F6.2090907@cogentembedded.com> <1402151680-11434-1-git-send-email-per.hurtig@kau.se> <1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com> <539413BA.7060903@kau.se> <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com> <5395B2FC.3070205@kau.se> <1402324388.3645.359.camel@edumazet-glaptop2.roam.corp.google.com> <5395C7E9.4050406@kau.se> <1402326259.3645.374.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?QW5uYSBCcnVuc3Ryw7Zt?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:50574 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933736AbaFIP4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 11:56:45 -0400
In-Reply-To: <1402326259.3645.374.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On m=C3=A5n  9 jun 2014 17:04:19, Eric Dumazet wrote:
> On Mon, 2014-06-09 at 16:42 +0200, Per Hurtig wrote:
>> Tried to run the script, but I don't have the "common/defaults" and =
the
>> test scripts from the git repository fails on all TCP tests for Linu=
x.
>> The results I listed in the enclosed packet traces are from two real
>> machines communicating with each other (with fresh net-next kernels =
and
>> TLP without the zero probe check), so I tend to rely more on those
>> results.
>
> Do not top post on netdev.
>
> We at Google run about 1000 packet drill tests for any functional cha=
nge
> in TCP stack. This is the only way we can scale.
>
> We are not 'studying by hand' various tcpdumps when a tool can do it
> properly.
>
> Nandita asked you give a pointer to the source code explaining how fa=
st
> retransmit was done for this specific case, but you provided a tcpdum=
p,
> which hardly can be reproduced and be the answer to the question.
>
> So now, we are trying to have a test to reproduce the issue and check
> the fix is complete.
>
> So far, I am not really convinced. It seems the FIN _is_ retransmitte=
d,
> but I do not see the SACK for this RTX is properly handled in time.
>
> Its one thing checking the FIN is retransmitted, its another to check
> that the SACK will trigger sensible behavior.
>
> If you carefully check your tcpdump, you'll see there is the same
> problem, and you missed it, while packetdrill exactly pointed it.
>
> Thanks
>
>

Ok, I guess you mean that the retransmission was not fast enough? But=20
will the same not happen if the original FIN is not lost and triggers a=
=20
SACK (i.e., if the two last data segments are still lost)?

Cheers,
Per
