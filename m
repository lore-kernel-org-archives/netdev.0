From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection
 establishment with the data
Date: Wed, 21 Mar 2012 17:00:52 -0700
Message-ID: <1332374452.9433.15.camel@edumazet-glaptop>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:54346 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab2CVAAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 20:00:55 -0400
Received: by dajr28 with SMTP id r28so2269941daj.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 17:00:55 -0700 (PDT)
In-Reply-To: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-21 at 16:38 -0700, Vincent Li wrote:
> Hi,
> 
> I happen to see this link
> http://h20000.www2.hp.com/bc/docs/support/SupportManual/c02020743/c02020743.pdf
> and
> 
> tcp_delay_final_twh_ack:
>             Piggyback the final ACK of the three way TCP connection
>             establishment with the data by delaying the final ack by
>            10ms.
> 
>            0: Send the final ACK as soon as the SYN+ACK packet
>                arrives from the remote host.
> 
>            1: Delay the sending of the final ACK by 10ms. If
>                there is data available to be sent with in the
>                next 10ms, piggyback the ACK for the SYN.
> [0-1] Default: 1
> 
> It appears this feature is not available in kernel tcp implementation,
> is it trivial to make a custom patch to make this feature available?
> can someone give a hint on how to make a patch for this?
> 
> We had a situation that we want to make linux kernel tcp stack behave
> this way so we can reproduce another issue at hand.
> 

No kernel patch is needed, you already can do this on linux.

Check file net/ipv4/tcp_input.c lines around 5722
