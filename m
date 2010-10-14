From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Thu, 14 Oct 2010 06:44:05 +0000
Message-ID: <20101014064404.GA6219@ff.dom.local>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com> <4CB1A22B.9090701@gmail.com> <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com> <20101012101022.GA8578@ff.dom.local> <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com> <20101012215932.GA1945@del.dom.local> <4CB4DE6E.7030802@hp.com> <20101013062649.GA6915@ff.dom.local> <20101013233653.1e363692.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38401 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191Ab0JNHqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 03:46:34 -0400
Received: by bwz15 with SMTP id 15so175603bwz.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 00:46:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101013233653.1e363692.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 13, 2010 at 11:36:53PM -0400, Bill Fink wrote:
> On Wed, 13 Oct 2010, Jarek Poplawski wrote:
> 
> > On Tue, Oct 12, 2010 at 03:17:18PM -0700, Rick Jones wrote:
> > >>> my burst problem is the only semi-legitimate motivation i can think
> > >>> of. the only other possible motivations i can imagine are setting
> > >>> "limit" to buffer more than 4GB of packets and setting "rate" to
> > >>> something more than 32 gigabit; both of these seem kind of dubious. is
> > >>> there something else you had in mind?
> > >>
> > >>
> > >> No, mainly 10 gigabit rates and additionally 64-bit stats.
> > >
> > > Any issue for bonded 10 GbE interfaces?  Now that the IEEE have ratified 
> > > (June) how far out are 40 GbE interfaces?  Or 100 GbE for that matter.
> > 
> > Alas packet schedulers using rate tables are still around 1G. Above 2G
> > they get less and less accurate, so hfsc is recommended.
> 
> I was just trying to do an 8 Gbps rate limit on a 10-GigE path,
> and couldn't get it to work with either htb or tbf.  Are you
> saying this currently isn't possible?

Let's start from reminding that no precise packet scheduling should be
expected with gso/tso etc. turned on. I don't know current hardware
limits for such a non-gso traffic, but for 8 Gbit rate htb or tbf
would definitely have wrong rate tables (overflowed values) for packet
sizes below 1500 bytes.

> Or are you saying to use
> this hfsc mechanism, which there doesn't seem to be a man page
> for?

There was a try:
http://lists.openwall.net/netdev/2009/02/26/138

Jarek P.
