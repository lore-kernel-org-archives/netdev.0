From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: TCP_NOTSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 10:18:02 -0700
Message-ID: <1374599882.3449.46.camel@edumazet-glaptop>
References: <1374550027.4990.141.camel@edumazet-glaptop>
	 <51EEA089.3040904@hp.com> <1374594244.3449.13.camel@edumazet-glaptop>
	 <51EEAD54.2040603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:50649 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757667Ab3GWRSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 13:18:04 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so8695665pbc.15
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 10:18:03 -0700 (PDT)
In-Reply-To: <51EEAD54.2040603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 09:20 -0700, Rick Jones wrote:

> Isn't this change really just trying to paper-over the autotuning's 
> over-growing of the socket buffers?  Or are you considering it an 
> extension of the auto-tuning heuristics?
> 
> If your 20Gbit test setup needed only 256KB socket buffers (figure 
> pulled form the ether) to get to 17 Gbit/s, isn't the autotuning's 
> growing them to several MB a bug in the autotuning?


As long as we limit the number of unsent bytes, there is no longer an
over provisioning problem.

TCP stack will be able to use the large windows if _needed_ by current
network conditions, receiver (in)ability to drain the data, and if
allowed by congestion control constraints.

If now you are complaining that TCP congestion controls are bad, thats a
completely different story, and this patch does not claim to solve this.
