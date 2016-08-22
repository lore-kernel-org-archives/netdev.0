From: Florian Westphal <fw@strlen.de>
Subject: Re: Patch to netfilter conntrack for secondary connection logging
Date: Mon, 22 Aug 2016 11:00:08 +0200
Message-ID: <20160822090008.GB6199@breakpoint.cc>
References: <1471831902045.98124@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34496 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932220AbcHVJAL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 05:00:11 -0400
Content-Disposition: inline
In-Reply-To: <1471831902045.98124@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Winter <Thomas.Winter@alliedtelesis.co.nz> wrote:
> Hello,
> 
> We are using netfilter to implement a firewall for a router and we had the problem that the ftp data connections were not being logged.
> I did some investigating and found that it is conntrack that is allowing the secondary connection by the ftp helper module.
> I created a patch to enable such logging for any conntrack helper.
> Is this a good change? Or did I miss something really obvious?

It should be possible to log the data connections via

-p tcp -m conntrack --ctstate RELATED -m helper --helper ftp -j (NF)LOG
