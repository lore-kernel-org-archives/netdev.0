From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Tuning TCP send on ethernet
Date: Wed, 08 Apr 2015 05:29:30 -0700
Message-ID: <1428496170.25985.218.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CALJd4cZpffegZ7RQ_QkRbbeQDUpUwK1peYe14PxpgZkbwsfUCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ashoka K <ashok.vinu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35331 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbbDHM3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 08:29:32 -0400
Received: by iggg4 with SMTP id g4so37667225igg.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 05:29:32 -0700 (PDT)
In-Reply-To: <CALJd4cZpffegZ7RQ_QkRbbeQDUpUwK1peYe14PxpgZkbwsfUCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-08 at 16:51 +0530, Ashoka K wrote:
> Hi ,
> 
> I have a question regarding TCP send queue on ethernet 100Mbps line.
> If you could answer it would be of great help.
> 
> We have a Linux based ARM system. Basically it capture image and
> transfer images on request to a windows client. During image transfer
> the softirq are seen in high number. These softirq are from network
> device which transfer image data. Due to this we see that other
> processes got hit in performance. For us the priority for sending the
> image data is low and we expect that this send should not block or
> slow down other running processes in system.
> 
> The image data is sent on particular TCP port say 2000. Only this
> transfer of image traffic has to be slowed/or whatever so that this
> does not affect other processes running on device. The maximum size of
> image is only 1.4 MB.
> 
> There is other less TCP traffic on other ports. These traffic include
> the commands sent to the device and command responses. This must not
> be affected severely.
> 
>  How to tune this? Device uses Linux 2.6.33 cross compiled for ARM,
> and it has 1 ethernet interface of speed 100Mbps, has 1GHz CPU.
> 
> I tried to modify ethernet "txqueuelen" from default 1000  to  a min
> of 1 to a max of 8000. But i didn't see improvement in behavior.
> 
> DO I have to modify  /kernel/softirq.c:
> 
>    #define     MAX_SOFTIRQ_RESTART  10
> 
> to smaller value ? What effects it may have? Or any other better solutions?

I guess you could either :

1) Set/force a low SO_SNDBUF value on the tcp socket used to transfer
the image if you have access to code source.

  int val = 8192;
  setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &val, sizeof(val));

2) lower /proc/sys/net/ipv4/tcp_wmem to enforce low buffers for all tcp
sockets.

 (Lower last column to say 90000 )


This wont help if the client is very close and rtt is small.
