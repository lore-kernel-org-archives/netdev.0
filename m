From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP stops sending packets over loopback on 4.10-rc3?
Date: Wed, 25 Jan 2017 06:25:11 -0800
Message-ID: <1485354311.5145.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485256853.4014.0@smtp.office365.com>
         <1485266868.16328.292.camel@edumazet-glaptop3.roam.corp.google.com>
         <1485353664.5902.2@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Lawrence Brakmo <brakmo@fb.com>,
        Kernel Team <kernel-team@fb.com>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35950 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752033AbdAYOZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 09:25:13 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so19848692pgf.3
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 06:25:13 -0800 (PST)
In-Reply-To: <1485353664.5902.2@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 09:14 -0500, Josef Bacik wrote:
> On Tue, Jan 24, 2017 at 9:07 AM, Eric Dumazet <eric.dumazet@gmail.com> 

> > 
> > git grep -n SOCK_QUEUE_SHRUNK
> > 
> > -> tcp_check_space()
> 
> But tcp_check_space() doesn't actually reduce sk_wmem_queued from what 
> I can see.  The only places that appear to reduce it are tcp_trim_head, 
> which is only called in the retransmit path, and sk_wmem_free_skb, 
> which seems to be right,

This is exactly how it works.

We free a bunch of skbs (an ACK can acknowledge dozens of them), and set
the SOCK_QUEUE_SHRUNK.

Then later, tcp_check_space() is called once and check if the bit was
set by a prior call to tcp_trim_head() or full skb freeing.

>  but I added a trace_printk() in it to see if 
> it was firing during my test and it never fires.  So we _appear_ to 
> only ever be incrementing this counter, but never decrementing it.  I'm 
> doing a bunch of tracing trying to figure out what is going on here but 
> so far nothing is popping which is starting to make me think ftrace is 
> broken.  Thanks,
> 

Just to make sure, are you telling use native/standard TCP is broken
over loopback, or is that only when using an additional kernel module ?
