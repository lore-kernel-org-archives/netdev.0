From: "SANGTAE HA" <sangtae.ha@gmail.com>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 11:49:47 -0500
Message-ID: <649aecc70702130849s6f70bf37y1f8177060d433ce0@mail.gmail.com>
References: <20070212191101.GP25760@galon.ev-en.org>
	 <20070212.122058.63127043.davem@davemloft.net>
	 <20070212221241.GQ25760@galon.ev-en.org>
	 <20070212.145351.35661569.davem@davemloft.net>
	 <20070213095613.GR25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: "Baruch Even" <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:31568 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbXBMQtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 11:49:50 -0500
Received: by nf-out-0910.google.com with SMTP id o25so355496nfa
        for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 08:49:48 -0800 (PST)
In-Reply-To: <20070213095613.GR25760@galon.ev-en.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Baruch,

I would like to add some comments on your argument.

On 2/13/07, Baruch Even <baruch@ev-en.org> wrote:
> * David Miller <davem@davemloft.net> [070213 00:53]:
> > From: Baruch Even <baruch@ev-en.org>
> > Date: Tue, 13 Feb 2007 00:12:41 +0200
> >
> > > The problem is that you actually put a mostly untested algorithm as the
> > > default for everyone to use. The BIC example is important, it was the
> > > default algorithm for a long while and had implementation bugs that no
> > > one cared for.
> >
> > And if our TCP Reno implementation had some bugs, what should
> > we change the default to?  This is just idiotic logic.
> >
> > These kinds of comments are just wanking, and lead to nowhere,
> > so please kill the noise.
> >
> > If we have bugs in a particular algorithm, we should just fix
> > them.
>
> I hope you've finished attempting to insult me. But I hope it won't
> prevent you from getting back to the topic. The above quote of me was a
> prelude to show the repeat behaviour where bic was added without
> testing, modified by Stephen and made default with no serious testing of
> what was put in the kernel.


What kind of serious testing you want to? I've been testing all
highspeed protocols including BIC and CUBIC for two and half years
now. Even Stephen didn't test CUBIC algorithm by himself, he might see
the results from our experimental studies. I don't care what algorithm
is default in kernel, however, it is not appropriate to get back to
Reno. As Windows decided to go with "Compound TCP", why we want to
back to 80's algorithm?


>
> It seems this happens again no with cubic. And you failed to respond to
> this issue.
>
> > > The behaviour of cubic wasn't properly verified as the
> > > algorithm in the linux kernel is not the one that was actually proposed
> > > and you intend to make it the default without sufficient testing, that
> > > seems to me to be quite unreasonable.
>
> According to claims of Doug Leith the cubic algorithm that is in the
> kernel is different from what was proposed and tested. That's an
> important issue which is deflected by personal attacks.

Did you read that paper?
http://wil.cs.caltech.edu/pfldnet2007/paper/CUBIC_analysis.pdf
Then, please read the rebuttal for that paper.
http://www.csc.ncsu.edu/faculty/rhee/Rebuttal-LSM-new.pdf

Also, the implementation can be different. The cubic code inside of
current kernel introduces faster calculation of cubic root. Even
though we had some bugs on CUBIC implementation, it is fixed now.


> > My main gripe is that there is a run to make an untested algorithm the
> default for all Linux installations. And saying that I should test it is
> not an escape route, if it's untested it shouldn't be made the default
> algorithm.

What is criteria for "untested"?  Who judges that this algorithm is
fully tested and is ready to use?

Could you tell me some other groups did more testing than ours?

Dummynet Testbed Result
http://netsrv.csc.ncsu.edu/highspeed/
http://netsrv.csc.ncsu.edu/convex-ordering/
http://www.csc.ncsu.edu/faculty/rhee/export/comnet-v3-rhee.pdf

Real testing between Korea and Japan (Seoul-Daejon-Busan-Japan)
http://netsrv.csc.ncsu.edu/highspeed/exp/

We still do testing with latest kernel version on production
networks(4ms, 6ms, 9ms, 45ms, and 200ms). I will post the results when
those are ready.


>
> My skimming of the PFLDNet 2007 proceedings showed only the works by
> Injong and Doug on Cubic and Injong tested some version on Linux
> 2.6.13(!) which might noe be the version in the current tree. Doug shows
> some weaknesses of the Cubic algorithm as implemented in Linux.

As I mentioned, please read the paper and rebuttal carefully. Also, in
PFLDnet 2007, Prof. R. Srikant proposed a new algorithm that uses BIC
and CUBIC curve based on delay estimation even he didn't know about
BIC and CUBIC before. I felt the CUBIC algorithm itself is not a bad
idea as other newly proposed algorithms follow BIC and CUBIC
approaches. I admit all proposed algorithms have their advantages over
others.

> Do you still think that making Cubic the default is a good idea?

Then, what do you want to make a default? You want to get back to BIC? or Reno?

>
> Baruch
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Sangtae
