From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Tue, 12 Mar 2013 08:29:53 -0600
Message-ID: <513F3BE1.2080409@genband.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>	 <1362888229.4051.2.camel@edumazet-glaptop>	 <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>	 <1362891937.4051.25.camel@edumazet-glaptop>	 <20130310004904.de508bfa.billfink@mindspring.com> <1362894876.4051.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, Vimal <j.vimal@gmail.com>,
	netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og127.obsmtp.com ([64.18.2.210]:48136 "EHLO
	exprod7og127.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694Ab3CLOaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 10:30:30 -0400
In-Reply-To: <1362894876.4051.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2013 11:54 PM, Eric Dumazet wrote:
> On Sun, 2013-03-10 at 00:49 -0500, Bill Fink wrote:
>
>> I don't see the problem.  An old program would not know about
>> the new multiplier, would thus get the default multiplier of 1,
>> and get the same behavior as always, with the same limitation
>> of ~34 Gbps.  But someone with a newer tc/kernel could for example
>> specify a multiplier of 10, which would then support rates up to
>> about 340 Gbps.  It sounds like a reasonable approach to me.
>
> Hopefully, some of us see the problem here and are able to reject
> patches before breaking user land.

The only problem I see is that you can't set the multiplier with a new 
tool and then query the rate with old tools.

But you're going to run into that problem with the old tools no matter 
what you do--and not doing anything is a crappy option as well.

Some kind of multiplier or shift makes as much sense as anything else. 
With old tools you get current behaviour, with new tools you can specify 
a multiplying factor to trade off resolution vs precision.

Chris
