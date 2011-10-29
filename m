From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Sat, 29 Oct 2011 15:32:25 +0300
Message-ID: <CAEnQRZCggUnoVZXyXfZ6-Om+hwQL_6Oo3dPODsXAH+iJYqN=jw@mail.gmail.com>
References: <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com>
	<20111028.183107.2091450715774357523.davem@davemloft.net>
	<4EAB2F58.7080509@hp.com>
	<20111028.222430.1568567893138453593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rick.jones2@hp.com, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, luto@amacapital.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:37773 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932425Ab1J2Mc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 08:32:26 -0400
Received: by qabj40 with SMTP id j40so4259675qab.19
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2011 05:32:25 -0700 (PDT)
In-Reply-To: <20111028.222430.1568567893138453593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 29, 2011 at 5:24 AM, David Miller <davem@davemloft.net> wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 28 Oct 2011 15:40:24 -0700
>
>> That would be loads faster, but won't that have issues with
>> granularity?
>
> Frankly, I don't care.
>
> For an obscure feature I don't even like to begin with, I refuse
> to allow a multiply into a core code path.

I agree that there is no place for multiplication.

I think the best way to go right now is as follows:
* make TCP Delack params configurable per socket.
* count number of bytes instead of number of segments.

Although, I like more to have tcp_delack_thresh
measured in number of segments instead of number
of bytes I don't see yet a neat solution of how to avoid
the multiplication (shift count is not acceptable because it
limits the available number of segments).

Any comments?

thanks,
Daniel.
