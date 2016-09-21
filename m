From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Wed, 21 Sep 2016 10:16:49 +0200
Message-ID: <20160921101649.44894f5b@redhat.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
        <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
        <20160920102943.24732097@brouer.com>
        <20160920133300.144037fd@redhat.com>
        <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
        <20160920154036.GA98644@ast-mbp.thefacebook.com>
        <84150f05-7eb3-d35c-32fd-4b9853f6f114@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>, brouer@redhat.com
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37188 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752502AbcIUIQy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 04:16:54 -0400
In-Reply-To: <84150f05-7eb3-d35c-32fd-4b9853f6f114@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Sep 2016 10:57:34 +0300
Tariq Toukan <ttoukan.linux@gmail.com> wrote:

> On 20/09/2016 6:40 PM, Alexei Starovoitov wrote:
> > On Tue, Sep 20, 2016 at 03:53:10PM +0300, Tariq Toukan wrote:  
> >>>>> +	case XDP_ABORTED:  
> >>>> It is not clearly defined, but I believe XDP_ABORTED should also result
> >>>> in a warning (calling bpf_warn_invalid_xdp_action(act)).  
> >> I'll add this.  
> > Certainly NOT.
> > XDP_ABORTED is an exception case when program does divide by zero.
> > It should NOT do bpf_warn. It must drop the packet.
> > We discussed it several months ago.
> > See mlx4/en_rx.c for canonical implementation.
> >  
> This is also the example given here:
> https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/xdp_actions.html#code-example
> 

Nice, the documentation is already useful :-)))

I actually adjusted the code example after this feedback. Which I also
wrote in this email thread about updating the documentation.  I already
pointed to this commit, but here is a more specific link:

https://github.com/netoptimizer/prototype-kernel/commit/3925249089ae4#diff-c9b8ab4ded3eed2e92f8d898111d8e9bL74


> I prefer to align with the documentation (and with current mlx4 driver 
> code), which means keeping the XDP_ABORTED w/o a warning.
> Anyway, I don't think this should block the coming V2. If you decide to 
> change documentation/specification, we will simply adjust our drivers 
> accordingly.

This is not blocking your V2, please resend so we can all start working
on a common code base for mlx5 (I'm currently running mlx5 with my own
one-page-per-packet patch... and my page_pool on-top)

As discussed in this thread, the outcome will likely be a new interface
for Troubleshooting and Monitoring, as documented and summarized here
so we don't forget:

https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/userspace_api.html#troubleshooting-and-monitoring

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
