From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Fri, 15 Aug 2003 15:28:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815142813.GB16560@mail.jlokier.co.uk>
References: <3F16A0E5.1080007@hipac.org> <1059934468.1103.41.camel@jzny.localdomain> <3F2E5CD6.4030500@hipac.org> <1060012260.1103.380.camel@jzny.localdomain> <3F302E04.1090503@hipac.org> <1060286331.1025.73.camel@jzny.localdomain> <3F381B3E.6080807@hipac.org> <20030811224050.59bc36fe.davem@redhat.com> <20030812142913.GB18802@mail.jlokier.co.uk> <3F390A23.3050409@hipac.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
Content-Disposition: inline
In-Reply-To: <3F390A23.3050409@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Bellion and Thomas Heinz wrote:
> >This generalises to multiple dimensions e.g. for doing multiple
> >prefixes on source+target + different combinations of other bits such
> >as protocol, TOS etc. - i.e. arbitrary bit-subset classifiers.  The
> >basic principle and the algorithm are the same.
> 
> Hm, how do you want to solve the d-dimensional PCP by
> doing binary search for each dimension? Remember that
> PCP is not related to longest prefix matching. Instead
> priorities are used.

I don't know what you mean by "PCP", so can't answer the question.

> Maybe you should describe in little more detail what you mean
> by "This generalises to multiple dimensions ...".

I mean that the lookup algorithm works for multi-dimensional searches.
Creating the search tree can be a little more involved, and I am not
sure how much (if any) node duplication is needed when some kinds of
rule priorities are used.

It may help to say that you don't have to do binary search for each
dimension separately, although that is a possible strategy for prefix
matching.

You can build a tree where each node represents a point (a,b,c...) in
prefix-length space, and whose children are other points in that
space, if you choose to see the general problem as matching multiple
prefixes.

At one extreme, a general bit matcher (i.e. no non-power-of-2
numerical ranges) can be treated as a multi-dimensional prefix match
where each prefix is length 0 or 1.  You see that, if the input rule
set is _equivalent_ to a longest-prefix single-dimensional rule set,
the optimal multi-dimensional search tree is trivally found and it
does not do binary search on each dimension separately.

-- Jamie
