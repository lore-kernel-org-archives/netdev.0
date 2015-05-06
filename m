From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] pktgen: introduce xmit_mode 'rx_inject'
Date: Wed, 6 May 2015 13:22:55 +0200
Message-ID: <20150506132255.71297bab@redhat.com>
References: <20150505202730.8715.48527.stgit@ivy>
	<20150505202959.8715.51882.stgit@ivy>
	<55499996.2090308@plumgrid.com>
	<20150506072440.7afb2c44@redhat.com>
	<5549EA1E.6040708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812AbbEFLXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 07:23:16 -0400
In-Reply-To: <5549EA1E.6040708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 06 May 2015 12:17:02 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/06/2015 07:24 AM, Jesper Dangaard Brouer wrote:
> > On Tue, 05 May 2015 21:33:26 -0700
> > Alexei Starovoitov <ast@plumgrid.com> wrote:
> >> On 5/5/15 1:30 PM, Jesper Dangaard Brouer wrote:
> >>>
> >>> Introduce xmit_mode 'rx_inject' for pktgen which generates the packets
> >>> using familiar pktgen commands, but feeds them into
> >>> netif_receive_skb() instead of ndo_start_xmit().
> >> ...
> >>> pgset "xmit_mode rx_inject"
> >>
> >> I think 'xmit_mode rx_inject' would make native english speaker cringe,
> >> since it's saying 'transmit mode is receive' ... but I don't mind :)
> >
> > Yes, I know. Like Daniel suggested, I considered only calling it "rx"
> > but it made me cringe for this exact reason, thus I extended it with
> > "inject".  I'm flexible with the name of this...
> 
> I don't mind how you name it eventually. ;) 'xmit_mode' I think is
> good, and rx|tx would be symmetric. I believe you don't like "rx" due
> to these two out-of-tree pktgen projects you mentioned having rx
> capabilities. Is that correct? 

Not correct, I really don't care about the two out-of-tree pktgen projects.

My main concern is to avoid polluting the pktgen "user-interface" (more
than it already is), with a bare option like "rx" which is in no-way
descriptive of its functionality.

> From my perspective, it would be more
> worth however to improve packet sockets and eBPF that could already
> do the same thing instead of a dedicated possible pktgen receive/
> capturing device for such analysis. Anyway, I can also live with a
> rx_inject.

We could call it "stack_inject" instead? ... to take out the confusing
"rx" part of an "transmit/xmit" mode that "receives".

If someone have time, I would like to see better tools that allow us to
measure different parts of the stack.  For now, this is what we got.
And this feature provide an easy and quick way to measure the ingress
code-path, which have gotten a lot of discussion lately... which after
this patch can easily be resolved by measuring instead of hand-waving ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
