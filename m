From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] skb truesize last offenders
Date: Fri, 23 Mar 2012 11:55:19 -0700
Message-ID: <1332528919.2516.2.camel@edumazet-glaptop>
References: <1332507112.4858.12.camel@edumazet-laptop>
	 <20120323.143826.1042705555491529895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wey-yi.w.guy@intel.com,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40300 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2CWSzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 14:55:21 -0400
Received: by iagz16 with SMTP id z16so4997367iag.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 11:55:21 -0700 (PDT)
In-Reply-To: <20120323.143826.1042705555491529895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-23 at 14:38 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 23 Mar 2012 05:51:52 -0700
> 
> > iwlwifi and some other users of skb_add_rx_frag() lie about skb
> > truesize, because of API being lazy.
> > 
> > iwlwifi can use order-0 or order-1 pages and skb truesize is wrong.
> > network sbs can use uncharged kernel memory and eventually crash machine
> > in OOM.
> > 
> > I plan : 
> > 
> > 1) adding a @truesize parameter to skb_add_rx_frag() in a neutral patch
> > 
> > 2) fix drivers that dont charge the real size of fragment
> > 
> > 3) niu could then use skb_add_rx_frag() instead of custom code.
> 
> No objections from me.  But we really have to fix that
> tcp_grow_window() issue, it's quite urgent if you ask me.

Sure, I can work on this issue with Neal asap, we do have some ideas on
this subject.
