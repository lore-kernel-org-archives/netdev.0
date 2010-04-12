From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH] iproute2: add option to build m_xt as a tc module.
Date: Mon, 12 Apr 2010 20:13:59 +0200
Message-ID: <20100412181359.GA4612@amd64.fatal.se>
References: <20100412115538.GA28338@amd64.fatal.se>
 <20100412083317.0d9e9f3f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:40551 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab0DLSM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 14:12:29 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 74C47E855A
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 20:12:27 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20100412083317.0d9e9f3f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 12, 2010 at 08:33:17AM -0700, Stephen Hemminger wrote:
> On Mon, 12 Apr 2010 13:55:38 +0200
> Andreas Henriksson <andreas@fatal.se> wrote:
> 
> > Add TC_CONFIG_XT_MODULE option that can be added
> > either to Config (after ./configure) or as an argument to "make".
> 
> I like the idea and will incorporate it, but do not like having more
> build options. Adding more configuration options like this is just
> lazy design "we can't figure this out, let's make the user do it".
> 
> So put the patch in but there it will always be true.

Sure..... unfortunately I found problems for the patch to work.
(dlopen needs full path and module name needs to match action name)
Will send new patch as a followup to this mail.

Note: I'm not a user of any of this functionality. (including "make install"!)
I've tried testing "action ipt" with m_xt.so now, but m_xt_old.so is
completely untested!

I used the following command when testing m_xt.so:
tc qdisc add dev lo ingress
tc filter add dev lo parent ffff: protocol ip prio 1 u32  match ip src 127.1.1.1/32 action ipt -j FOOBAR

...which gave me the error "failed to find target FOOBAR",
and this is to me an indication of success since I don't have that target.

-- 
Andreas Henriksson
