From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 06:44:59 -0700
Message-ID: <1401284699.5367.268.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	 <1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACP96tRBiANHxXSFZ_w7eKwO_zWk_AZv-7CDJFLSP6+bZJLZ5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56563 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbaE1NpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 09:45:04 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so11214180pbb.33
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 06:45:03 -0700 (PDT)
In-Reply-To: <CACP96tRBiANHxXSFZ_w7eKwO_zWk_AZv-7CDJFLSP6+bZJLZ5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-28 at 08:18 -0400, sowmini varadhan wrote:
> On Tue, May 27, 2014 at 9:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Last time I checked, we were spending _lot_ of time in check_lifetime()
> 
> Although check_lifetime() itself did not light up in my
> perf output, i see your point- it has a few ifa_list walks
> that might end up being expensive - but these are static
> IPv4 addresses- they should be marked IFA_F_PERMANENT,
> right? That's probably why they did not show up in my perf output?


How did you run perf ?

If you run :

perf record ./your_script.sh

It wont catch all the load that is triggered from work queues.

If you do

./your_script.sh &

perf top

Then you'll see check_lifetime() at first position.
