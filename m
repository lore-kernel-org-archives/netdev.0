From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Fri, 19 May 2017 21:13:14 -0700
Message-ID: <20170519211314.5a14a402@cakuba.netronome.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512210827.14733.13997041998775151648.stgit@firesoul>
        <20170520030750.c2b55oqdms5n764c@ast-mbp>
        <20170519202147.3c6bda7f@cakuba.netronome.com>
        <20170520033358.hjz7ocy2fupwplym@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:13972 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751153AbdETENi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 May 2017 00:13:38 -0400
In-Reply-To: <20170520033358.hjz7ocy2fupwplym@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 May 2017 20:34:00 -0700, Alexei Starovoitov wrote:
> On Fri, May 19, 2017 at 08:21:47PM -0700, Jakub Kicinski wrote:
> > On Fri, 19 May 2017 20:07:52 -0700, Alexei Starovoitov wrote:  
> > > How about exposing 'struct mlx5_cqe64 *' to XDP programs as-is?
> > > We can make sure that XDP program does read only access into it and
> > > it will see cqe->rss_hash_result, cqe->rss_hash_type and everything else
> > > in there, but this will not be uapi and it will be pretty obvious
> > > to program authors that their programs are vendor specific.
> > > 'not uapi' here means that mellanox is free to change their HW descriptor
> > > and its contents as they wish.  
> > 
> > Hm..  Would that mean we have to teach the verifier about all possible
> > drivers and their metadata structures (i.e. sizes thereof).  And add an
> > UAPI enum of known drivers?  
> 
> why? no uapi other than a pointer to this hw rx descriptor.
> Different sizeof(hw_rx_descriptor) is not a problem.
> We deal with it already in tracing. All tracepoints have different
> sizeof(*ctx), yet the safety is preserved.

Ack, quick read of tracing code reveals this indeed should work.
