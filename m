From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Mon, 30 Jan 2017 21:13:46 -0800
Message-ID: <20170130211346.6d637248@cakuba>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
        <20170131044745.GA8082@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <michael.chan@broadcom.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:24560 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751463AbdAaFUt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 00:20:49 -0500
In-Reply-To: <20170131044745.GA8082@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2017 20:47:47 -0800, Alexei Starovoitov wrote:
> On Mon, Jan 30, 2017 at 08:49:25PM -0500, Michael Chan wrote:
> > The first 8 patches refactor the code (rx/tx code paths and ring logic)
> > and add the basic infrastructure to support XDP.  The 9th patch adds
> > basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
> > completes the series with XDP_TX.  
> 
> Looks great.
> Could you please share performance numbers ?
> 
> Also please add something like:
>   if (prog && prog->xdp_adjust_head) {
>           netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
>           return -EOPNOTSUPP;
>   }
> unless you plan to add adjut_head support until net-next closes.
> Note, it's must have for load balancer functionality.

I was about to ask whether it's OK at this point to add XDP support
without xdp_adjust_head()?  My understanding was that this is basic
functionality and therefore required?

FWIW the check you requested is there in patch 9.
