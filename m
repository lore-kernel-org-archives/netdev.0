From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 21:56:58 +0200
Message-ID: <20160921215658.2c61ed5e@redhat.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
        <1474408824-418864-2-git-send-email-tom@herbertland.com>
        <20160920224416.GF3291@pox.localdomain>
        <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
        <20160920230927.GG3291@pox.localdomain>
        <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
        <20160920234347.GH3291@pox.localdomain>
        <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
        <20160921115545.GA12789@pox.localdomain>
        <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
        <20160921144800.GB13991@pox.localdomain>
        <CALx6S36ZCdh5iOp6CPfztVKOEkDFgUo1RyqWMJVxhakOYNx8iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60312 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755582AbcIUT5F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 15:57:05 -0400
In-Reply-To: <CALx6S36ZCdh5iOp6CPfztVKOEkDFgUo1RyqWMJVxhakOYNx8iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 21 Sep 2016 08:08:34 -0700 Tom Herbert <tom@herbertland.com> wrote:

> On Wed, Sep 21, 2016 at 7:48 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 09/21/16 at 07:19am, Tom Herbert wrote:  
> >> certain design that because of constraints on one kernel interface. As
> >> a kernel developer I want flexibility on how we design and implement
> >> things!  
> >
> > Perfectly valid argument. I reviewed your ILA changes and did not
> > object to them.
> >
> >  
> >> I think there are two questions that this patch set poses for the
> >> community wrt XDP:
> >>
> >> #1: Should we allow alternate code to run in XDP other than BPF?
> >> #2: If #1 is true what is the best way to implement that?
> >>
> >> If the answer to #1 is "no" then the answer to #2 is irrelevant. So
> >> with this RFC I'm hoping we can come the agreement on questions #1.  

I vote yes to #1.

> > I'm not opposed to running non-BPF code at XDP. I'm against adding
> > a linked list of hook consumers.

I also worry about the performance impact of a linked list.  We should
simple benchmark it instead of discussing it! ;-)


> > Would anyone require to run XDP-BPF in combination ILA? Or XDP-BPF
> > in combination with a potential XDP-nftables? We don't know yet I
> > guess.
> >  
> Right. Admittedly, I feel like we owe a bit of reciprocity to
> nftables. For ILA we are using the NF_INET_PRE_ROUTING hook with our
> own code (looks like ipvlan set nfhooks as well). This works really
> well and saves the value of early demux in ILA. Had we not had the
> ability to use nfhooks in this fashion it's likely we would have had
> to create another hook (we did try putting translation in nftables
> rules but that was too inefficient for ILA).

Thinking about it, I actually think Tom is proposing a very valid user
of the XDP hook, which is the kernel itself.  And Tom even have a real
first user ILA.  The way I read the ILA-RFC-draft[1], the XDP hook
would benefit the NVE (Network Virtualization Edge) component, which
can run separately or run on the Tenant System, where the latter case
could use XDP_PASS.

[1] https://www.ietf.org/archive/id/draft-herbert-nvo3-ila-02.txt
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
