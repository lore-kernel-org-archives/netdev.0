From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/1] driver: veth: Refine the statistics
 codes of veth driver
Date: Thu, 03 Nov 2016 06:30:58 -0700
Message-ID: <1478179858.7065.438.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478178237-23020-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, cwang@twopensource.com, vijayp@vijayp.ca,
        ej@evanjones.ca, pabeni@redhat.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33486 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755895AbcKCNbA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:31:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id a136so4915901pfa.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:31:00 -0700 (PDT)
In-Reply-To: <1478178237-23020-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-03 at 21:03 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> The dropped count of veth is located in struct veth_priv, but other
> statistics like packets and bytes are in another struct pcpu_vstats.
> Now keep these three counters in the same struct.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v2: Use right "peer" instead of "dev";
>  v1: Initial version

May I ask : Why ?

We did that because there was no point making per-cpu requirements
bigger, for a counter that is hardly ever updated.

Do you have a real case where performance dropping packets in a driver
is needed ?

At some point we will have to stop dumb percpu explosion, when we have
128+ cores per host. Folding all these percpu counters is taking a lot
of time too.
