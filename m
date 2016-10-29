From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Refactor the XDP forwarding
 rings scheme
Date: Sat, 29 Oct 2016 16:18:57 -0700
Message-ID: <20161029231857.GA17767@gmail.com>
References: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
 <1477579924-32737-3-git-send-email-tariqt@mellanox.com>
 <20161028010701.GB49550@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33884 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752380AbcJ2XTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 19:19:01 -0400
Received: by mail-pf0-f178.google.com with SMTP id n85so56372240pfi.1
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 16:19:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161028010701.GB49550@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 06:07:02PM -0700, Alexei Starovoitov wrote:
> On Thu, Oct 27, 2016 at 05:52:04PM +0300, Tariq Toukan wrote:
> > Separately manage the two types of TX rings: regular ones, and XDP.
> > Upon an XDP set, do not borrow regular TX rings and convert them
> > into XDP ones, but allocate new ones, unless we hit the max number
> > of rings.
> > Which means that in systems with smaller #cores we will not consume
> > the current TX rings for XDP, while we are still in the num TX limit.
> 
> The commit log is too scarce for details...
> So questions:
> - Did you test with changing the number of channels after xdp prog is loaded?
> That was the recent bug that Brenden fixed.
> - does it still have 256 tx queue limit or xdp tx rings can go over?
> - Any performance implications ?
> 
> Brenden, could you please review this patch?
Sure, sorry for the delay...was traveling.
> 
