From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 19:28:52 +0100
Message-ID: <20110118182852.GC4202@del.dom.local>
References: <20110118172340.GB1843@del.dom.local>
 <AANLkTikUPRfYupw1-Py5mHeN+pFv-zMKhmK3DKixxsH4@mail.gmail.com>
 <alpine.LNX.2.01.1101181921320.17010@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alessandro Suardi <alessandro.suardi@gmail.com>,
	jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	pablo@netfilter.org, arthur.marsh@internode.on.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59195 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab1ARS27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 13:28:59 -0500
Received: by ewy5 with SMTP id 5so3491790ewy.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 10:28:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1101181921320.17010@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 07:24:40PM +0100, Jan Engelhardt wrote:
> 
> On Tuesday 2011-01-18 19:10, Alessandro Suardi wrote:
> >On Tue, Jan 18, 2011 at 6:23 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> >>
> >> NLM_F_DUMP flags should be applied to GET requests only, eg. rtnetlink
> >> tests message type to verify this. Since genetlink can't do the same
> >> use "practical" test for ops->dumpit (assuming NEW request won't be
> >> mixed with GET).
...
> >2.6.37-git18 + netlink revert + this patch
> > - fixes Avahi
> > - breaks acpid
> >Starting acpi daemon: RTNETLINK1 answers: Operation not supported
> >acpid: error talking to the kernel via netlink
> 
> Deducing from that, it is a GET-like request that was sent by acpid, 
> and the message type is one that has both a dumpit and a doit function.
> So if EOPNOTSUPP now occurs on all message types that have both dumpit 
> and doit, you should have broken a lot more than just acpid.

Right, we need something better here.

Jarek P.
