From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] net: introduce noref sk
Date: Thu, 21 Sep 2017 03:37:56 -0700
Message-ID: <1505990276.29839.120.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1505926196.git.pabeni@redhat.com>
         <20170920.202022.2073272587145961156.davem@davemloft.net>
         <1505986931.2560.51.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        pablo@netfilter.org, fw@strlen.de, edumazet@google.com,
        hannes@stressinduktion.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:55399 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdIUKh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 06:37:59 -0400
Received: by mail-it0-f42.google.com with SMTP id 4so103028itv.4
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:37:59 -0700 (PDT)
In-Reply-To: <1505986931.2560.51.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-09-21 at 11:42 +0200, Paolo Abeni wrote:
> Hi,
> 
> Thanks for the feedback!
> 
> On Wed, 2017-09-20 at 20:20 -0700, David Miller wrote:
> > From: Paolo Abeni <pabeni@redhat.com>
> > Date: Wed, 20 Sep 2017 18:54:00 +0200
> > 
> > > This series introduce the infrastructure to store inside the skb a socket
> > > pointer without carrying a refcount to the socket.
> > > 
> > > Such infrastructure is then used in the network receive path - and
> > > specifically the early demux operation.
> > > 
> > > This allows the UDP early demux to perform a full lookup for UDP sockets,
> > > with many benefits:
> > > 
> > > - the UDP early demux code is now much simpler
> > > - the early demux does not hit any performance penalties in case of UDP hash
> > >   table collision - previously the early demux performed a partial, unsuccesful,
> > >   lookup
> > > - early demux is now operational also for unconnected sockets.
> > > 
> > > This infrastrcture will be used in follow-up series to allow dst caching for
> > > unconnected UDP sockets, and than to extend the same features to TCP listening
> > > sockets.
> > 
> > Like Eric, I find this series (while exciting) quite scary :-)
> > 
> > You really have to post some kind of performance numbers in your
> > header posting in order to justify something with these ramifications
> > and scale.
> 
> This is actually a preparatory work for the next series which will
> bring in the real gain. The next patches are still to be polished so we
>  posted this separately to get some early feedback. 
> 
> If that would help, I can post the follow-up soon as RFC. Overall -
> with the follow-up appplied, too - when using a single rx ingress
> queue, I measured ~20% tput gain for unconnected ipv4 sockets - with
> rp_filter disabled - and ~30% for ipv6 sockets. In case of multiple
> ingress queues, the gain is smaller but still measurable (roughly 5%). 
> 
> Please let me know if you prefer the see the full work early. 

I want to see the full work yes. Ipv6, and everything.

I do not want ~1000 lines of changed code in the stack for some corner
cases, where people do not properly use existing infra, like proper
SO_REUSEPORT with proper BPF filter to have as many clean siloes (proper
CPU/NUMA affinities to avoid QPI traffic)

The complexity of your patches reached a point where I am extremely
nervous.

Thanks.
