From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Tue, 20 Nov 2007 16:22:18 +0300
Message-ID: <20071120132218.GA6180@2ka.mipt.ru>
References: <200711182131.38388.ismail@pardus.org.tr> <474093E0.3090007@unsolicited.net> <47409863.8000902@trash.net> <4741DB3A.2030304@unsolicited.net> <20071119192423.GA26449@2ka.mipt.ru> <20071119193143.GA12640@2ka.mipt.ru> <4741EB07.50706@unsolicited.net> <20071120115520.GB30752@2ka.mipt.ru> <4742CEDF.2020102@trash.net> <4742D1F1.20805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David <david@unsolicited.net>,
	Ismail =?utf8?Q?D=C3=B6nmez?= <ismail@pardus.org.tr>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55162 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbXKTNWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 08:22:49 -0500
Content-Disposition: inline
In-Reply-To: <4742D1F1.20805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 01:24:17PM +0100, Patrick McHardy (kaber@trash.net) wrote:
> Patrick McHardy wrote:
> >Evgeniy Polyakov wrote:
> >>>>>Ok, let's try it hard way.
> >>>>>Please check attached patch and tell if it helped (it will produce
> >>>>>some debug though).
> >>>>With both patches applied - one Patrick showed and this one.
> >>>>  
> >>>Now works, with this in dmesg
> >>>
> >>>conntrack: ea94159c, new: ead4d7c4, old: ead4d7d0, ct: 00000000.
> >>
> >>David (Miller :), please apply attached patch, which also needed to fix
> >>netfilter connection tracking bug.
> >>When connection tracking entry (nf_conn) is about to copy itself it can
> >>have some of its extension users (like nat) as being already freed and
> >>thus not required to be copied.
> >>Frankly saying, it can be not the correct fix, but from code observation
> >>and test, perfomed by David <david@unsolicited.net> it is.
> >
> >I also don't believe this can be correct, let me look into this
> >first.
> 
> 
> I now understand whats happening:
> 
> - new connection is allocated without helper
> - connection is REDIRECTed to localhost
> - nf_nat_setup_info adds NAT extension, but doesn't initialize it yet
> - nf_conntrack_alter_reply performs a helper lookup based on the
>   new tuple, finds the SIP helper and allocates a helper extension,
>   causing reallocation because of too little space
> - nf_nat_move_storage is called with the uninitialized nat extension
> 
> So your fix is entirely correct, thanks a lot :)

It is always better to check my third eye revelations :)
Thanks for checking it.

-- 
	Evgeniy Polyakov
