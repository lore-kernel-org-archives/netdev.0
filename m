From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/7] packet: rollover huge flows before small
 flows
Date: Wed, 06 May 2015 13:16:00 -0700
Message-ID: <1430943360.14545.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
	 <1430936837-22655-7-git-send-email-willemb@google.com>
	 <1430940864.14545.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+FuTSfQ5vXQeo8FqU-hi3zTqu4hx+JqJmNbmRp95M0O3um1kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36064 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbEFUQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 16:16:02 -0400
Received: by iecnq11 with SMTP id nq11so23680658iec.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 13:16:01 -0700 (PDT)
In-Reply-To: <CA+FuTSfQ5vXQeo8FqU-hi3zTqu4hx+JqJmNbmRp95M0O3um1kA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-06 at 16:06 -0400, Willem de Bruijn wrote:

> Do you suggest running lockless, similar to the rfs table?
> I can reduce history length to make hist_idx fit in the same
> cacheline.

I suggest not using hit_idx at all, and no lock either.

for (i = 0; i < ROLLOVER_HLEN; i++)
      if (po->rollover->history[i] == rxhash)
              count++;

po->rollover->history[prandom_u32() % ROLLOVER_HLEN] = rxhash;
