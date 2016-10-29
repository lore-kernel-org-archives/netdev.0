From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 17/17] batman-adv: Avoid precedence issues in macros
Date: Fri, 28 Oct 2016 18:56:24 -0700
Message-ID: <1477706184.23018.3.camel@perches.com>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
         <20161027190150.7880-18-sw@simonwunderlich.de>
         <1477689186.23018.1.camel@perches.com> <4261316.fWqmHPy2zE@sven-edge>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Wunderlich <sw@simonwunderlich.de>, davem@davemloft.net,
        netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Antonio Quartulli <a@unstable.cc>
To: Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0123.hostedemail.com ([216.40.44.123]:33413 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753039AbcJ2B4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 21:56:30 -0400
In-Reply-To: <4261316.fWqmHPy2zE@sven-edge>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-28 at 23:27 +0200, Sven Eckelmann wrote:
> On Freitag, 28. Oktober 2016 14:13:06 CEST Joe Perches wrote:
> > On Thu, 2016-10-27 at 21:01 +0200, Simon Wunderlich wrote:
> > > From: Sven Eckelmann <sven@narfation.org>
> > > 
> > > It must be avoided that arguments to a macro are evaluated ungrouped (which
> > > enforces normal operator precendence). Otherwise the result of the macro
> > > is not well defined.
> > 
> > Curiosity:
> > 
> > in net/batman-adv/tp_meter.c
> 
> [...]
> > 	orig_node = batadv_orig_hash_find(bat_priv, tp_vars->other_end);
> > 	if (unlikely(!orig_node)) {
> > 		err = BATADV_TP_REASON_DST_UNREACHABLE;
> > 		tp_vars->reason = err;
> > 		goto out;
> > 	}
> > 
> > 	primary_if = batadv_primary_if_get_selected(bat_priv);
> > 	if (unlikely(!primary_if)) {
> > 		err = BATADV_TP_REASON_DST_UNREACHABLE;
> > 		goto out;
> > 	}
> > 
> > err is not used in the out block
> > 
> > Is the last if block supposed to set tp_vars->reason to err?
> 
> This seems to be unrelated to this patch.

Kinda.  I was looking at how the one instance of
batadv_tp_is_error was used and it's in this file.

> But yes, looks to me like it is missing. Do you want to propose a patch or
> should I do?

As you are working on this file, perhaps you should.

cheers, Joe
