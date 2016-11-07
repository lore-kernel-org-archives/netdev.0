From: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Subject: Re: [PATCH net] Fixes: 5943634fc559 ("ipv4: Maintain redirect and
 PMTU info in struct rtable again.")
Date: Mon, 7 Nov 2016 18:05:33 -0500
Message-ID: <20161107230533.GA16422@ssuryaputra-desktop>
References: <1478531058-12701-1-git-send-email-ssurya@ieee.org>
 <1478534932.17367.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161107.112016.598403889913912857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34005 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbcKGXFh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 18:05:37 -0500
Received: by mail-qk0-f195.google.com with SMTP id 124so6414332qkh.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 15:05:37 -0800 (PST)
Received: from ssuryaputra-desktop ([12.38.14.193])
        by smtp.gmail.com with ESMTPSA id f16sm17737564qta.9.2016.11.07.15.05.35
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:05:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161107.112016.598403889913912857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did the temporary clearing/restoring rt_gateway following the deleted
function check_peer_redir(). But, looking again at the function the
assigning of peer->redirect_learned.a4 to rt_gateway can be permanent
because restoring to the old_gw only happens on errors.

I have updated the patch to use __ipv4_neigh_lookup().

Thank you.

On Mon, Nov 07, 2016 at 11:20:16AM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 07 Nov 2016 08:08:52 -0800
> 
> > In any case, rt is a shared object at that time, so even temporarily
> > clearing/restoring rt_gateway seems wrong to me.
> > 
> > I would rather call __ipv4_neigh_lookup(dst->dev, new_gw) directly at
> > this point.
> 
> Agreed.
