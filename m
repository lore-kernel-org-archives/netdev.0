From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 18:58:00 -0500
Message-ID: <20160129235800.GH17127@oracle.com>
References: <20160129180651.GA17127@oracle.com>
 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
 <20160129210900.GD17127@oracle.com>
 <CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
 <20160129230424.GG17127@oracle.com>
 <CALx6S34KtC4kkjzchY5Xs4QapD7FMqxShwEDST0Q_bZgDRicmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Dalton <mwdalton@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27567 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbcA2X6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 18:58:15 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S34KtC4kkjzchY5Xs4QapD7FMqxShwEDST0Q_bZgDRicmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/29/16 15:31), Tom Herbert wrote:
> But even within flow dissector, to be completely correct, we need to
> replace all 32-bit accesses with the mempy (flow_label, mpls label,
> keyid) and be vigilant about new ones coming in. For that matter, ..

well, one question that came to my mind when I was looking at this is:
why does eth_get_headlen try to compute the flow hash even before the
driver has had a chance to pull things into an aligned buffer? Isn't
that just risking even more unaligned accesses?
