From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 06 Aug 2014 16:37:03 +0200
Message-ID: <1407335823.11943.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
	 <1407204710-21778-6-git-send-email-willemb@google.com>
	 <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+FuTSf96KH=JkO4Va4pfbvYHngHjxtTc33ipbif_xC9kdgaLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:56398 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbaHFOhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 10:37:08 -0400
Received: by mail-we0-f173.google.com with SMTP id q58so2813085wes.4
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 07:37:06 -0700 (PDT)
In-Reply-To: <CA+FuTSf96KH=JkO4Va4pfbvYHngHjxtTc33ipbif_xC9kdgaLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-06 at 10:23 -0400, Willem de Bruijn wrote:
> > I believe you missed fact that a GSO packet can be split into 2 or many
> > skbs, when tcp_write_xmit() has to send a lower amount.
> >
> > This is done in tso_fragment()
> 
> Thanks, I missed that case. I'll look into it.
> 
> > Also, I am a bit worried about retransmits ?
> 
> For the same reason, i.e., possibly calling tcp_fragment?

Yes, but also that we're going to send multiple reports back to error
queue.
