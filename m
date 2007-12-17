From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: init_timer_deferrable conversion
Date: Mon, 17 Dec 2007 12:47:59 -0500
Message-ID: <82e4877d0712170947v45929acv92e0d34c86d82c6d@mail.gmail.com>
References: <Pine.LNX.4.64.0712162149220.4622@mini.warudkars.net>
	 <20071217095504.b02241ee.dada1@cosmosbay.com>
	 <20071217152943.10470215.dada1@cosmosbay.com>
	 <20071217090000.64499fba@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.181]:24492 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755251AbXLQRsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 12:48:01 -0500
Received: by el-out-1112.google.com with SMTP id v27so355995ele.23
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 09:48:00 -0800 (PST)
In-Reply-To: <20071217090000.64499fba@deepthought>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 17, 2007 12:00 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> > > >
> > > > a) drivers/net/sky2.c - watchdog_timer. This was showing up high on
> > > > Powertop's list of things that cause routine wakeups from idle. After
> > > > converting to init_timer_deferrable() the wakeups went down and this one
> > > > no longer shows up in powertop's list. 25% reduction.
>
> This surprises me because it is a 1 hz timer and uses round_jiffies() in
> the current kernel.

I am using the current git and I already have low wakeups per second
to begin with - 5-7  and out of that 25% are attributed to sky2. Not
sure if that matches up with the 1 hz + round_jiffies() logic.

But is it conceptually ok to make this deferrable? I suppose yes as
it's just a watchdog that checks if the link is up and delaying that
would not make a difference?

Thanks
Parag
