From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection
 establishment with the data
Date: Fri, 23 Mar 2012 12:11:12 -0700
Message-ID: <1332529872.2516.5.camel@edumazet-glaptop>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
	 <1332374452.9433.15.camel@edumazet-glaptop>
	 <CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
	 <1332458037.6521.12.camel@edumazet-glaptop>
	 <1332458223.6521.14.camel@edumazet-glaptop>
	 <CAK3+h2yFeww84QStvugyaYGfWsL2cw3TnG3CoeLk-q2pQ70_+w@mail.gmail.com>
	 <CAK6E8=dnYBLQm4eDh4HOeN_O8uRy8Gvf=PeuT69+6rycjRwRfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vincent Li <vincent.mc.li@gmail.com>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45447 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758223Ab2CWTLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 15:11:15 -0400
Received: by yenl12 with SMTP id l12so3032519yen.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 12:11:14 -0700 (PDT)
In-Reply-To: <CAK6E8=dnYBLQm4eDh4HOeN_O8uRy8Gvf=PeuT69+6rycjRwRfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-23 at 12:03 -0700, Yuchung Cheng wrote:

> AFAICT the feature that Eric refers to is TCP Fast Open that I am
> still testing and have not yet submit to netdev.
> 

Nope, I was referring to actual linux code ;)

TFO will permit to send the DATA in the SYN packet, while Vincent only
asked to send it in the second packet the client sends to server.

> But one way to achieve that currently is doing a non-blocking connect
> then a blocking write.
> 
> I just tried this on 2.6 machine to a remote server
> 
> fcntl(sd, F_SETFL, fcntl(sd, F_GETFL, 0) | O_NONBLOCK);
> connect(sd, ...);
> fcntl(sd, F_SETFL, fcntl(sd, F_GETFL, 0) & ~O_NONBLOCK);
> sendto(sd, buf, buf, 0, ...);
> 
> The key is that the socket has to be in progress of connecting
> when application calls write/sendto(2). If you are testing on loopback,
> the connect might finish before sendto so this won't work.
> 
