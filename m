From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v6 01/12] bpf: add XDP prog type for early driver filter
Date: Mon, 11 Jul 2016 15:53:46 +0200
Message-ID: <20160711155346.18839919@redhat.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	<1467944124-14891-2-git-send-email-bblanco@plumgrid.com>
	<CALx6S376Yds7wDa4Hi=p1N0iCWo7HV2ajPOCZ482LvYa6kHqkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917AbcGKNxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 09:53:53 -0400
In-Reply-To: <CALx6S376Yds7wDa4Hi=p1N0iCWo7HV2ajPOCZ482LvYa6kHqkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Jul 2016 16:04:16 -0500
Tom Herbert <tom@herbertland.com> wrote:

> > +/* User return codes for XDP prog type.
> > + * A valid XDP program must return one of these defined values. All other
> > + * return codes are reserved for future use. Unknown return codes will result
> > + * in driver-dependent behavior.
> > + */
> > +enum xdp_action {
> > +       XDP_DROP,
> > +       XDP_PASS,  
> 
> I think that we should be able to distinguish an abort in BPF program
> from a normal programmatic drop. e.g.:
> 
> enum xdp_action {
>       XDP_ABORTED = 0,
>       XDP_DROP,
>       XDP_PASS,
> };

I agree.  And maybe we can re-use the bpf_warn_invalid_xdp_action() call
to keep the branch/jump-table as simple as possible, handling the
distinguishing on the slow path.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
