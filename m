From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add rbnode to struct sk_buff
Date: Mon, 03 Nov 2014 14:36:04 -0800
Message-ID: <1415054164.1005.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M0--G=znvqQwy5Qmnm5po9yApcn4LjSSv8+-5c1D7RwQ@mail.gmail.com>
	 <20141103.163748.929657552226178600.davem@davemloft.net>
	 <CAHA+R7P9PgkitLZAZrEoFfXT290rVr4oFibPyODPWhSVitA1WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yaogong Wang <wygivan@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:54237 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaKCWgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 17:36:07 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so5538526igb.10
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 14:36:05 -0800 (PST)
In-Reply-To: <CAHA+R7P9PgkitLZAZrEoFfXT290rVr4oFibPyODPWhSVitA1WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 13:41 -0800, Cong Wang wrote:
> On Mon, Nov 3, 2014 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
> > From: Cong Wang <cwang@twopensource.com>
> > Date: Mon, 3 Nov 2014 13:34:33 -0800
> >
> >> No objections, but this is hacky, rbnode is larger than ->next + ->prev,
> >> this means ->tstamp is always overwritten. This is why netem saves it
> >> to its CB. This isn't flexible.
> >
> > It's the size of next+prev+tstamp.  Eric is showing exactly what is
> > shared with what with the struct/union layout.
> 
> I knew, I meant saving tstamp is not flexible, or at least not pretty. :)

Note that TCP stack doesn't care saving tstamp for packets in out of
order queue.

Even for netem, I am not sure it is needed at all.
