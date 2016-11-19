From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] virtio_net: add dedicated XDP transmit queues
Date: Fri, 18 Nov 2016 19:20:58 -0800
Message-ID: <1479525658.8455.313.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
         <20161118190041.16137.48399.stgit@john-Precision-Tower-5810>
         <20161118130953.7bf2d71d@laptop> <20161118181004.4c15a6a1@laptop>
         <582FBC6B.8000902@gmail.com> <20161118185728.67e2b53a@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, tgraf@suug.ch,
        shm@cumulusnetworks.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, davem@davemloft.net,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34859 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752176AbcKSDVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 22:21:01 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so22276230pga.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 19:21:01 -0800 (PST)
In-Reply-To: <20161118185728.67e2b53a@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-18 at 18:57 -0800, Jakub Kicinski wrote:
> On Fri, 18 Nov 2016 18:43:55 -0800, John Fastabend wrote:
> > On 16-11-18 06:10 PM, Jakub Kicinski wrote:
> > > On Fri, 18 Nov 2016 13:09:53 -0800, Jakub Kicinski wrote:  
> > >> Looks very cool! :)
> > >>
> > >> On Fri, 18 Nov 2016 11:00:41 -0800, John Fastabend wrote:  
> >  [...]  
> > >>
> > >> Is num_online_cpus() correct here?  
> > > 
> > > Sorry, I don't know the virto_net code, so I'm probably wrong.  I was
> > > concerned whether the number of cpus can change but also that the cpu
> > > mask may be sparse and therefore offsetting by smp_processor_id()
> > > into the queue table below could bring trouble.
> > >   
> > 
> > Seem like a valid concerns to me how about num_possible_cpus() instead.
> 
> That would solve problem 1, but could cpu_possible_mask still be sparse
> on strange setups?  Let me try to dig into this, I recall someone
> (Eric?) was fixing similar problems some time ago.

nr_cpu_ids is probably what you want ;)
