From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Mon, 30 Jan 2017 20:47:47 -0800
Message-ID: <20170131044745.GA8082@ast-mbp.thefacebook.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35583 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750799AbdAaErw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 23:47:52 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so25760748pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 20:47:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 08:49:25PM -0500, Michael Chan wrote:
> The first 8 patches refactor the code (rx/tx code paths and ring logic)
> and add the basic infrastructure to support XDP.  The 9th patch adds
> basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
> completes the series with XDP_TX.

Looks great.
Could you please share performance numbers ?

Also please add something like:
  if (prog && prog->xdp_adjust_head) {
          netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
          return -EOPNOTSUPP;
  }
unless you plan to add adjut_head support until net-next closes.
Note, it's must have for load balancer functionality.
