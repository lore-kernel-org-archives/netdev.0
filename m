From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Thu, 5 Jan 2017 09:03:21 +0100
Message-ID: <20170105080320.GA4827@penelope.horms.nl>
References: <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <586ADAFE.1010105@gmail.com>
 <13dfd148-6a5b-cf62-b2b9-1c13e6d31155@mojatatu.com>
 <586B29A4.2060408@gmail.com>
 <92224e21-cd3c-26b0-d8a0-31a07268e553@mojatatu.com>
 <606f64cb-1744-d44f-8fd1-a4bdb1ca872f@mellanox.com>
 <20170104101437.GB24762@penelope.horms.nl>
 <786655e9-de6a-29e9-a043-207afedcedc2@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f174.google.com ([209.85.210.174]:34018 "EHLO
        mail-wj0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968428AbdAEIDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 03:03:25 -0500
Received: by mail-wj0-f174.google.com with SMTP id tn15so28899849wjb.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 00:03:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <786655e9-de6a-29e9-a043-207afedcedc2@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 01:45:28PM +0200, Paul Blakey wrote:
> On 04/01/2017 12:14, Simon Horman wrote:
> >On Tue, Jan 03, 2017 at 02:22:05PM +0200, Paul Blakey wrote:
> >>
> >>On 03/01/2017 13:44, Jamal Hadi Salim wrote:
> >>>On 17-01-02 11:33 PM, John Fastabend wrote:
> >>>>On 17-01-02 05:22 PM, Jamal Hadi Salim wrote:
> >>>[..]
> >>>>>Like all cookie semantics it is for storing state. The receiver
> >>>>>(kernel)
> >>>>>is not just store it and not intepret it. The user when reading it back
> >>>>>simplifies what they have to do for their processing.
> >>>>>
> >>>>>>The tuple <ifindex:qdisc:prio:handle> really should be unique why
> >>>>>>not use this for system wide mappings?
> >>>>>>
> >>>>>I think on a single machine should be enough, however:
> >>>>>typically the user wants to define the value in a manner that
> >>>>>in a distributed system it is unique. It would be trickier to
> >>>>>do so with well defined values such as above.
> >>>>>
> >>>>Just extend the tuple <hostname:ifindex:qdisc:prio:handle> that
> >>>>should be unique in the domain of hostname's, or use some other domain
> >>>>wide machine identifier.
> >>>>
> >>>May work for the case of filter identification. The nice thing for
> >>>allowing cookies is you can let the user define it define their
> >>>own scheme.
> >>>
> >>>>Although actions can be shared so the cookie can be shared across
> >>>>filters. Maybe its useful but it doesn't uniquely identify a filter
> >>>>in the shared case but the user would have to specify that case
> >>>>so maybe its not important.
> >>>>
> >>>Note: the action cookies and filter cookies are unrelated/orthogonal.
> >>>Their basic concept of stashing something in the cookie to help improve
> >>>what user space does (in our case millions of actions of which some are
> >>>used for accounting) is similar.
> >>>I have no objections to the flow cookies; my main concern was it should
> >>>be applicable to all classifiers not just flower. And the arbitrary size
> >>>of the cookie that you pointed out is questionable.
> >>>
> >>>cheers,
> >>>jamal
> >>
> >>Hi all,
> >>Our use case is replacing OVS rules with TC filters for HW offload, and
> >>you're are right the cookie would
> >>have saved us the mapping from OVS rule ufid to the tc filter handle/prio...
> >>that was generated for it.
> >>It also was going to be used to store other info like which OVS output port
> >>corresponds to the ifindex,
> >Possibly off-topic but I am curious to know why you need to store the port.
> >My possibly naïve assumption is that a filter is attached to the netdev
> >corresponding to the input port and mirred or other actions are used to output
> >to netdevs corresponding to output ports.
> 
> Right, its for the output ports, OVS uses ovs port numbers and mirred action
> uses the device ifindex, so there is need
> to translate it back to OVS port on dump.

Understood, that is a tedious abstraction to support.
But I don't see an easy way around it at this time.

If I read Jamal's emails correctly he is working on per-action cookies.
They may be better than per-flow cookies for storing the OvS port number
(though not the UUID of the flow).

...
