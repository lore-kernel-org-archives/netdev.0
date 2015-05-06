From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 6/7] packet: rollover huge flows before small flows
Date: Wed, 6 May 2015 16:19:36 -0400
Message-ID: <CA+FuTScaDNf2OfjbSN8aSvQz+e_USDh7EuNZDLrhGhfe1rDXrQ@mail.gmail.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
 <1430936837-22655-7-git-send-email-willemb@google.com> <1430940864.14545.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+FuTSfQ5vXQeo8FqU-hi3zTqu4hx+JqJmNbmRp95M0O3um1kA@mail.gmail.com> <1430943360.14545.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36038 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbEFUUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 16:20:07 -0400
Received: by obbkp3 with SMTP id kp3so16074604obb.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 13:20:06 -0700 (PDT)
In-Reply-To: <1430943360.14545.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2015 at 4:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-05-06 at 16:06 -0400, Willem de Bruijn wrote:
>
>> Do you suggest running lockless, similar to the rfs table?
>> I can reduce history length to make hist_idx fit in the same
>> cacheline.
>
> I suggest not using hit_idx at all, and no lock either.
>
> for (i = 0; i < ROLLOVER_HLEN; i++)
>       if (po->rollover->history[i] == rxhash)
>               count++;
>
> po->rollover->history[prandom_u32() % ROLLOVER_HLEN] = rxhash;

Thanks, I'll do that.
