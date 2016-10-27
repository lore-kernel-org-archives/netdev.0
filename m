From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCHv2 iproute2 net-next] tc: m_mirred: Fix parsing of 'index'
 optional argument
Date: Thu, 27 Oct 2016 11:46:33 +0200
Message-ID: <20161027094633.GR5640@orbyte.nwl.cc>
References: <20161027073606.6112-1-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38493 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942740AbcJ0Odl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 10:33:41 -0400
Content-Disposition: inline
In-Reply-To: <20161027073606.6112-1-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Oct 27, 2016 at 10:36:06AM +0300, Shmulik Ladkani wrote:
> Code in parse_mirred() suggests "index" argument can be placed either
> after the egress/ingress clause, or as the first argument (after
> "action mirred").
> 
> However, parse_direction() fails to correctly parse "index" if it's the
> first argument.
> 
> For example:
> 
>  # tc filter add ... action mirred index 5
>  RTNETLINK answers: Invalid argument
>  (unnecessary RTNETLINK issued, should have been parse error)
> 
>  # tc filter add ... action mirred index 5 egress redirect dev eth0
>  bad action type egress
>  (should have been parsed successfully)

According to the action's help text (and the man page which is based
upon that), this behaviour is perfectly fine:

| Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME>

So first argument *must* be the direction, second one *must* be the
action, then an optional index and the last one *must* be the interface.

While I don't see a problem with changing that (apart from that I don't
think it's necessary), if you change it you should adjust help text and
man page accordingly.

But is all this really worth it? And if so, why not fix the parser for
good by delaying the whole validation (apart from double arg detection)
until after the parsing itself?

Cheers, Phil
