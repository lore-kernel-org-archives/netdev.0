From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Route cache performance
Date: Fri, 16 Sep 2005 02:21:02 +0400
Message-ID: <20050915222102.GA30387@yakov.inr.ac.ru>
References: <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <17182.64751.340488.996748@robur.slu.se> <20050907162854.GB24735@netnation.com> <20050907195911.GA8382@yakov.inr.ac.ru> <20050913221448.GD15704@netnation.com> <20050915210432.GD28925@yakov.inr.ac.ru> <17193.59406.200787.819069@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Simon Kirby <sim@netnation.com>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <17193.59406.200787.819069@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>  No. There must be an explanation... I've seen around 1 Mpps in the best
>  single flow tests w. 2.6 kernels of course decent HW. Simon can you 
>  report in pps as you use 64 byte pkts.

Sender: 367 Mbps, 717883 pps valid src/dst, 64 byte (Ethernet) packets

2.4.27-rc1: 297 Mbps forwarded (w/idle time?!)

So, his best number is (717883/367)*297 ~= 580kpps

>  Yes. I'll guess the thinking was that RCU is for read mostly

RCU should not add essential overhead to DoS, actually. The difference
between direct dst_free and RCU is strange as well.


>  Also interesing to get BSD numbers? Sounds like they use something like
>  old FASTROUTE.

Yes, it is quite funny. I guess it required irq protection to radix tree
manipulations, grr... Anyway, I would expect BSD with fastforwarding beat
NAPI.

Alexey
