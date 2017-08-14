From: Thiago Macieira <thiago.macieira@intel.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Mon, 14 Aug 2017 09:06:35 -0700
Message-ID: <2828157.5Eig1SAfYW@tjmaciei-mobl1>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33902 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752150AbdHNQHG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 12:07:06 -0400
In-Reply-To: <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 14 August 2017 08:03:50 PDT Willem de Bruijn wrote:
> > I'm actually surprised that only unix sockets can have negative values. 
> > Is
> > there a reason for that?  I had assumed that sk_set_peek_off would allow
> > negative values as the code already has to support negative values due to
> > what the initial value is.
> 
> A negative initial value indicates that PEEK_OFF is disabled. It only
> makes sense to peek from a positive offset from the start of the data.

But here's a question: if the peek offset is equal to the length, should the 
reading return an empty datagram? This would indicate to the caller that there 
was a datagram there, which was skipped over.

That's how we deal with empty datagrams anyway.

-- 
Thiago Macieira - thiago.macieira (AT) intel.com
  Software Architect - Intel Open Source Technology Center
