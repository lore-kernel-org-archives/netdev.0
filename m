From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCHv2 iproute2 net-next] tc: m_mirred: Fix parsing of
 'index' optional argument
Date: Thu, 27 Oct 2016 17:22:39 +0300
Message-ID: <20161027172239.7bf5cc40@pixies>
References: <20161027073606.6112-1-shmulik.ladkani@gmail.com>
        <20161027094633.GR5640@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35322 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941393AbcJ0OWs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:22:48 -0400
Received: by mail-wm0-f44.google.com with SMTP id e69so38129411wmg.0
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:22:47 -0700 (PDT)
In-Reply-To: <20161027094633.GR5640@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil,

On Thu, 27 Oct 2016 11:46:33 +0200, phil@nwl.cc wrote:
> According to the action's help text (and the man page which is based
> upon that), this behaviour is perfectly fine:
> 
> | Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME>
> 
> So first argument *must* be the direction, second one *must* be the
> action, then an optional index and the last one *must* be the interface.

There is an inconsistency betweem man/help and code.

Actual code, since first committed, attempts to parse "index" as 1st
argument (without success), see parse_mirred():

	if (matches(*argv, "egress") == 0 || matches(*argv, "index") == 0) {
		int ret = parse_egress(a, &argc, &argv, tca_id, n);

> While I don't see a problem with changing that (apart from that I don't
> think it's necessary)

Not "changing" per-se, but rather "fixing", at least according code
author's intention :)

As I suggested in the notes part of the commit log,

>> An alternative solution: banning "index" as 1st argument in parse_mirred

I ok with removing the code trying to support "index" as 1st argument as
well.
I only assumed one might want this behaviour due to intention expressed
by original code.
