From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Wed, 7 Oct 2009 17:03:30 -0700
Message-ID: <55a4f86e0910071703i4735f1aan1ddba81eec7eef19@mail.gmail.com>
References: <200910051646.34770.atis@mikrotik.com>
	 <20091007.031957.197632672.davem@davemloft.net>
	 <200910071559.56526.atis@mikrotik.com>
	 <20091007.135627.96995518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: atis@mikrotik.com, netdev@vger.kernel.org, panther@balabit.hu,
	eric.dumazet@gmail.com, brian.haley@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:46230 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbZJHAEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 20:04:08 -0400
Received: by bwz6 with SMTP id 6so403976bwz.37
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 17:03:30 -0700 (PDT)
In-Reply-To: <20091007.135627.96995518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should wrapping a packet into a tunnel clear the mark?
Should perhaps the mark be a parameter of the tunnel (like ttl or qos,
can be set or can be inherited)?

On Wed, Oct 7, 2009 at 13:56, David Miller <davem@davemloft.net> wrote:
> From: Atis Elsts <atis@mikrotik.com>
> Date: Wed, 7 Oct 2009 15:59:56 +0300
>
>> Here is the sk_mark part.
>
> Applied, thanks.
>
>> As for the ipmr.c code, I agree with your comment. Using mark from
>> skb probably is wrong in case of tunnel interface (i.e. in the "if
>> (vif->flags&VIFF_TUNNEL)" part of the patch), my mistake. I still
>> think that the "else" part is correct, though, because using mark
>> from skb there mirrors behaviour for unicast forwarding routing
>> lookup in ip_route_input_slow(). The same applies to IPv6 code in
>> ip6mr_forward2().
>
> Ok submit just the else part and we'll have a look at it.
>
> Thanks.
>
