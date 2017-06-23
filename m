From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] xdp: offload mode
Date: Fri, 23 Jun 2017 13:42:39 -0400 (EDT)
Message-ID: <20170623.134239.2137839647545874564.davem@davemloft.net>
References: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com, kafai@fb.com,
        daniel@iogearbox.net
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754209AbdFWRml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 13:42:41 -0400
In-Reply-To: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 21 Jun 2017 18:25:02 -0700

> While we discuss the representors.. :)
> 
> This set adds XDP flag for forcing offload and a attachment mode
> for reporting to user space that program has been offloaded.  The
> nfp driver is modified to make use of the new flags, but also to
> adhere to the DRV_MODE flag which should disable the HW offload.
> 
> The intended driver behaviour is:
>             DRV mode   offload
> no flags      yes     attempted
> DRV_MODE      yes        no
>  HW_MODE      no         yes
> 
> Where 'yes' means required, and error will be returned if setup fails.
> 'Attempted' means the offload will only happen automatically if HW is
> capable and offloading the program will cause no change in system
> behaviour (e.g. maps don't have to bound).
> 
> Thanks to loading the program both to the driver and HW by default we
> can fallback to the driver mode without disruption in case user replaces
> the program with one which cannot be offloaded later.
> 
> Note that the NFP driver currently claims XDP offload support but 
> lacks most basic features like direct packet access.
> 
> Only change compared to the RFC is fixing the double bpf_prog_put()
> which Daniel has spotted (patch 5).

Applied, thank you.
