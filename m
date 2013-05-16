From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: gso: do not generate out of order packets
Date: Wed, 15 May 2013 21:46:48 -0700
Message-ID: <1368679608.4519.105.camel@edumazet-glaptop>
References: <1368668281.4519.75.camel@edumazet-glaptop>
	 <CAHo-OozZz4yx5iuoEWcq5vTJvJ0b_5bNbiQuc4PMw22jBZOxpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:51109 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab3EPEqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 00:46:50 -0400
Received: by mail-da0-f41.google.com with SMTP id y19so1417023dan.14
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 21:46:50 -0700 (PDT)
In-Reply-To: <CAHo-OozZz4yx5iuoEWcq5vTJvJ0b_5bNbiQuc4PMw22jBZOxpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 20:58 -0700, Maciej =C5=BBenczykowski wrote:

> Could we instead move the queue mapping into the skb somehow instead?

Quite frankly all the ndo_select_queue() / ARFS / XPS stuff are already
a mess.

You need a socket pointer to be able to change the queue numbers we
cache in it. We lack this information at GSO segmentation.

Let's do GSO properly and provide skbs exactly like if they were built
by TCP stack. (Well, there _is_ some difference, as the truesize will
have less overhead)
