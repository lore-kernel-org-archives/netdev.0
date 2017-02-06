From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 19:15:15 +0100
Message-ID: <20170206181515.GA19171@salvia>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170206110858.GA3896@salvia>
 <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
 <20170206141622.4szfsu6h4qqlhdvk@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>
To: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33922 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751946AbdBFSPV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 13:15:21 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 34235170D21
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 19:15:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 22672DA804
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 19:15:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D3135DA80B
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 19:15:16 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170206141622.4szfsu6h4qqlhdvk@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2017 at 03:16:22PM +0100, Harald Welte wrote:
> Hi Jonas,
> 
> On Mon, Feb 06, 2017 at 02:33:07PM +0100, Jonas Bonn wrote:
> > Fair enough.  The use-case I am looking at involves PGW load-testing where
> > the simulated load is generated locally on the SGSN so it _is_ seeing IP
> > packets and the SNDCP is left out altogether.  
> 
> Ok, it would have been useful to document that test-only feature in the
> changelog and/or code.  Like "support simulated RAN-side tunnels" or
> "support SGSN/S-GW simulation".

Right. Please, include this in your follow up v2 patch description.
BTW, please also indicate [PATCH net-next] for new features.

> > Perhaps this is too pathological to warrant messing with the upstream
> > driver... I don't know: the symmetry does not cost much even if it's
> > of limited use.
> 
> There are plenty of features in the mainline kernel related to testing,
> see pktgen for example.  So I think if it doesn't impose complexity,
> performance issues or stretches the existing architecture, I think
> there's no reason to keep it out.
> 
> Looking at the code, I think the one conditional on the flags is not
> going to kill significant performance of the "normal" use case.  But
> that's of course just guessing, without any benchmark to back that up.
> 
> Semantically, I'm not sure if the FLAGS and the re-use of the
> SGSN_ADDRESS TLV is the best choice.  If suddenly the meaning of the TLV
> is "Peer GSN Address" then it should be called that way.  We could have
> a #define SGSN_ADDRESS to GSN_PEER_ADDRESS to make old code compile.
> I'll let Pablo respond to this as he came up with the netlink interface,
> as far as I can remember :)

I agree with Harald that a new netlink TLV, ie. IFLA_GTP_MODE, to
indicate if this is expecting to operate on the GGSN or SGSN side
would be better. See include/uapi/linux/if_link.h.

Flags allows us to combine different features, in this case we won't
combine anything since these two modes are mutually exclusive.

> Also, like with any changes to the kernel and netlink interface code, I
> think we should always mandate similar changes to be made to libgtpnl so
> the feature can actually be used/tested with the standard
> tools/utilities available to anyone.

Yes, at least some scripts and short text file example would suffice.

Thanks!
