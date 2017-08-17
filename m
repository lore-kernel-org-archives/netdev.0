From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH next] neigh: initialize neigh entry correctly during arp
 processing
Date: Wed, 16 Aug 2017 20:32:15 -0400
Message-ID: <20170817003215.GQ6984@oracle.com>
References: <20170817000251.38469-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Reshetova Elena <elena.reshetova@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Ihar Hrachyshka <ihrachys@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37507 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdHQAc7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 20:32:59 -0400
Content-Disposition: inline
In-Reply-To: <20170817000251.38469-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (08/16/17 17:02), Mahesh Bandewar wrote:
> 
> From: Mahesh Bandewar <maheshb@google.com>
> 
> If the ARP processing creates a neigh entry, it's immediately marked
> as STALE without timer and stays that way in that state as long as
> host do not send traffic to that neighbour.

Perhaps I dont understand the specific  packet exchange case
that your patch is trying to fix,  but if the neighbor entry
is created as a result of an incoming packet (but we have not
yet sent anything to this neighbor) then it should be marked STALE?
IOW, STALE means "Ingress path claims this adjacency, but egress
path has not been verified".  Is the problem that the neigh never
goes into PROBE?

> +	if (neigh) {
> +		if (neigh->nud_state & NUD_VALID)
> +			neigh_update(neigh, lladdr, NUD_STALE,
> +				     NEIGH_UPDATE_F_OVERRIDE, 0);
> +		else
> +			neigh_event_send(neigh, NULL);
> +	}

NUD_VALID is already a mask of 
 (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
are you sure you want to force the transition of probe/delay -> stale
here? Maybe it woudl help to describe the exact wire packet
exchange that is broken today, but fixed by your patch.

--Sowmini
