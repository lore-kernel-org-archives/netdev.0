From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 02 Oct 2012 18:06:32 +0200
Message-ID: <1349193992.12401.800.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>
	 <20121002155738.GA20331@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63305 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab2JBQGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 12:06:37 -0400
Received: by bkcjk13 with SMTP id jk13so5609152bkc.19
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 09:06:35 -0700 (PDT)
In-Reply-To: <20121002155738.GA20331@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 11:57 -0400, Dave Jones wrote:

> 
> Good work! Any idea why it didn't happen on every build for me ?
> 
> From your description, this should have failed every time ?

Well, it seems that as long as you had forwarded packets and a route not
yet cached in nh_rth_input, we were using a brand new route (and correct
one)

But as soon as a locally generated traffic did cache a route in
nh_rth_input, forwarded packets immediately were using this cache and
were delivered (and dropped) to local host.

Maybe my patch is not the good fix, but at least its a step in
understanding the problem.

Thanks
