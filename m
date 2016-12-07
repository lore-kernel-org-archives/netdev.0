From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v3 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Wed, 7 Dec 2016 09:26:14 -0800
Message-ID: <20161207172614.GA5200@kafai-mba.local>
References: <1481088714-54512-1-git-send-email-kafai@fb.com>
 <1481088714-54512-2-git-send-email-kafai@fb.com>
 <5847D723.3020908@iogearbox.net>
 <20161207114112.6ad86da3@jkicinski-Precision-T1700>
 <20161207163756.GA33446@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jakub Kicinski <kubakici@wp.pl>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        "Jesper Dangaard Brouer" <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "Saeed Mahameed" <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "Kernel Team" <kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58634 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752479AbcLGR0n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:26:43 -0500
Content-Disposition: inline
In-Reply-To: <20161207163756.GA33446@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 08:37:58AM -0800, Alexei Starovoitov wrote:
> On Wed, Dec 07, 2016 at 11:41:12AM +0000, Jakub Kicinski wrote:
> > > I see nothing wrong if this is exposed/made visible in the usual way through
> > > ethtool -k as well. I guess at least that would be the expected way to query
> > > for such driver capabilities.
> >
> > +1 on exposing this to user space.  Whether via ethtool -k or a
> > separate XDP-specific netlink message is mostly a question of whether
> > we expect the need to expose more complex capabilities than bits.
>
> I'm very much against using NETIF_F_ flags and exposing this to user space.
> I see this xdp feature flag as temporary workaround until all drivers
> support adjust_head() helper. It is very much a fundamental feature for xdp.
> Without being able to add/remove headers the usability of xdp becomes very limited.
>
> If you guys dont like extra ndo_xdp command, I'd suggest to do
> "if (prog->xdp_adjust_head)" check in the driver and if driver doesn't
> support it yet, just fail XDP_SETUP_PROG command.
> imo that will be more flexible interface, since in the future drivers
> can fail on different combination of features and simple boolean flag
> unlikely to serve us for long time.
It makes sense that adjust_head() will eventually be supported by
all xdp-capable driver.  If that is the case, lets check
prog->xdp_adjust_head inside the driver instead of adding
another ndo_xdp command which will become unuseful very soon.
