From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 10:33:05 -0800
Message-ID: <1354127585.14302.467.camel@edumazet-glaptop>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	 <50B4F2DA.8020206@hp.com>
	 <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
	 <20121127.210611.1127622873924794001.davem@davemloft.net>
	 <20121128072611.GA26010@pob.ytti.fi>
	 <CAGK4HS_GVZqoGVjd87N6skM-SBWyPtY-AhiR9FDcR8ty5x6Xbg@mail.gmail.com>
	 <20121128085404.GB26010@pob.ytti.fi>  <50B656CC.1040001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saku Ytti <saku@ytti.fi>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50498 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab2K1SdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:33:12 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so9916864pbc.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 10:33:11 -0800 (PST)
In-Reply-To: <50B656CC.1040001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 10:24 -0800, Rick Jones wrote:
> On 11/28/2012 12:54 AM, Saku Ytti wrote:
> > On (2012-11-28 00:35 -0800), Vijay Subramanian wrote:
> >
> >> Also note that reordering is tracked on the sender side using the
> >> per flow variable tp->reordering . This measures the amount of
> >> reordering on the connection so that fast retransmit and other loss
> >> recovery mechanisms are not entered prematurely. Doesn't this
> >> behavior at the  sender already provide the behavior you seek?
> >
> > Sorry I don't seem to understand what you mean. Do you mind explaining how
> > the sender can help to restore performance on reordering network?
> 
> tp->reordering is initialized via the sysctl net.ipv4.tcp_reordering 
> which controls how anxious TCP will be to fast retransmit.
> 
> By increasing net.ipv4.tcp_reordering you make the sending TCP less 
> "sensitive" to duplicate ACKs and so less sensitive to reordering 
> detected by the receiver.  The receiver is generating as many 
> (duplicate) ACKs as before, it is just that the sender is ignoring them 
> a bit more.

Note that this sysctl controls the initial value of the per socket
reordering value. It _does_ increase automatically (assuming SACK is
enabled of course)
