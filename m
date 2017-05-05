From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next ] tcp: add new parameter tcp_inherit_buffsize
 to control the initial buffer size for new passive connetion
Date: Fri, 05 May 2017 06:52:26 -0700
Message-ID: <1493992346.7796.43.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAPYxyxJYXA_maME_qnshnFdzwDUkU1PvgDBQMfH32EerfQJZxA@mail.gmail.com>
         <1493737515.31837.42.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAPYxyxJBPO6W_wjYwXZQ5DS0sFjLh+A_GPSz1qn6qRZkqhMFQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?=E5=8D=95=E5=8D=AB?= <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34895 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751489AbdEENxR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 09:53:17 -0400
Received: by mail-pg0-f46.google.com with SMTP id o3so3342658pgn.2
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 06:52:46 -0700 (PDT)
In-Reply-To: <CAPYxyxJBPO6W_wjYwXZQ5DS0sFjLh+A_GPSz1qn6qRZkqhMFQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-05-05 at 18:22 +0800, 单卫 wrote:
> 
> 
> 2017-05-02 23:05 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
>         
>         
>         Hi Shan
>         
>         1) Your patch never reached netdev, because it was sent in
>         HTML format.
>         
>         2) During Linus merge window, net-next is closed
>         
>         I am not really convinced that we need this with TCP
>         autotuning anyway.
>         Initial value of sk_sndbuf and sk_rcvbuf is really a hint.
>         
>         How often do you really tweak /proc/sys/net/ipv4 files in
>         production.
> 
> 
> 
Again you posted your reply in HTML, so netdev did not get it.

> 
> Historically, most products have not adjusted any wmem/rmem
> parameters.
> In our experience to adjust the parameters, you can get a better visit
> experience, faster. 
> 
> Now more and more products want to change this default value.
> But for a product, once we adjust the parameters, it is rarely
> adjusted.
> 
> 
> We hope that this patch can provide a capacity: adjust the parameters
> online and quickly take effect.
> 
> Without this patch, it is time consuming for us to adjust the
> parameters and need to migrate flows.
> 
> 
> 
>          
>         Please provide more information, like what actual values you
>         change back
>         and forth.
>         
> 
> 
> There is no a fixed value here. big value, will take up more memory
> resources.
> But we are also willing to sacrifice memory for performance.
> 
> Select the parameter value based on the characteristics of the
> product.
> 
> 
> For example, for 1MB files, we will set buffsize to 1611646 = (1MB /
> 1460) * 2244
> Mss = 1460, SKB_TRUESIZE = 2244
> 
> 
> With TCP autotuning, reach the buffer size until the cwnd equal 359
> from 10.

Looks like a problem with autotuning because you might have HZ=100 or
HZ=250 maybe ?

We want to make autotuning better, so that tweaks like that are no
longer needed.



> 
> 
