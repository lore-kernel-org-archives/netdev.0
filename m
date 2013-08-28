From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Source routing without rules?
Date: Tue, 27 Aug 2013 18:46:35 -0700
Message-ID: <CALCETrWSgSnMdARZPGii5G1Yf43JjEPpeNgL2_yfDBd7W9650A@mail.gmail.com>
References: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com>
 <20130828011437.GA30092@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Andy Lutomirski <luto@amacapital.net>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:37499 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3H1Bqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 21:46:55 -0400
Received: by mail-vb0-f52.google.com with SMTP id f12so3534728vbg.39
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 18:46:55 -0700 (PDT)
In-Reply-To: <20130828011437.GA30092@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 6:14 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Tue, Aug 27, 2013 at 05:16:21PM -0700, Andy Lutomirski wrote:
>> I'm about to implement a trivial source routing policy for the third
>> time, and this is IMO stupid.  I want to have two routes to a network.
>>  Each route should specify a src, and, if the flow matches the src,
>> then that route should win.
>>
>> The rules that don't work are:
>>
>> ip route add <net> via <gw1> dev <dev1> metric 0
>> ip route add <net> via <gw2> dev <dev2> src <dev2addr> metric 10
>
> src is actually the preferred src address. In ipv6 land there is a RTA_SRC
> (look for ip route *from* parameter) route attribute settable to only
> select routes if the from-source matches the route. If you implement
> such a feature I would go with the same design (IPV6_SUBTREES).

Interesting.  The Kconfig help text for IPV6_SUBTREES is incredibly
confusing.  What are the actual semantics?  I'm guessing that only
routes that match the source address in their "from" clause are
considered and ties are broken in favor of the longest from prefix.

This is considerably more complicated than my suggestion, but it's
also more powerful.  Implementing this will require actually
understanding how the trie code works :/

--Andy
