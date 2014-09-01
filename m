From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Mon, 01 Sep 2014 10:07:39 +0930
Message-ID: <87k35okwfg.fsf@rustcorp.com.au>
References: <20140825.163458.1117073971092495452.davem@davemloft.net> <20140826082815.18034199@redhat.com> <20140826121347.0ec7f2ac@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, dborkman@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:53376 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbaIABb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2014 21:31:26 -0400
In-Reply-To: <20140826121347.0ec7f2ac@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> writes:
> On Tue, 26 Aug 2014 08:28:15 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>> On Mon, 25 Aug 2014 16:34:58 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>> 
>> > Given Jesper's performance numbers, it's not the way to go.
>> > 
>> > Instead, go with a signalling scheme via new boolean skb->xmit_more.
>> 
>> I'll do benchmarking based on this new API proposal today.
>
> While establish an accurate baseline for my measurements.  I'm
> starting to see too much variation in my trafgen measurements.
> Meaning that we unfortunately cannot use it to measure variations on
> the nanosec scale.
>
> I'm measuring the packets per sec via "ifpps", and calculating an
> average over the measurements, via the following oneliner:
>
>  $ ifpps -clod eth5 -t 1000 | awk 'BEGIN{txsum=0; rxsum=0; n=0} /[[:digit:]]/ {txsum+=$11;rxsum+=$3;n++; printf "instant rx:%u tx:%u pps n:%u average: rx:%d tx:%d pps\n", $3, $11, n, rxsum/n, txsum/n }'

FYI, this is what I use for this kind of thing:
 
       https://github.com/rustyrussell/stats

>From the README:
 This filter finds identical lines and collapses all the numbers into a
 range, average and standard deviation; it can also print out all the
 numbers in CSV form for import into spreadsheets, etc.

Cheers,
Rusty.
