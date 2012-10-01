From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: sysctl for initial receive window
Date: Mon, 1 Oct 2012 15:36:06 -0700
Message-ID: <CAK6E8=dU=JdgysTnZNAeDA_4nzMfExbXmjSmMBWGZb3Zog2ndg@mail.gmail.com>
References: <1348241111.2669.580.camel@edumazet-glaptop> <20120921.135601.254379488076661898.davem@davemloft.net>
 <1348252326.3103.90.camel@localhost> <20120921.144808.1893006476597754774.davem@davemloft.net>
 <1348660432.5093.353.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, brouer@redhat.com,
	netdev@vger.kernel.org, nanditad@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:47356 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2JAWg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 18:36:28 -0400
Received: by obbuo13 with SMTP id uo13so5555075obb.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 15:36:27 -0700 (PDT)
In-Reply-To: <1348660432.5093.353.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 26, 2012 at 4:53 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-09-21 at 14:48 -0400, David Miller wrote:
>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>> Date: Fri, 21 Sep 2012 20:32:06 +0200
>> > The would defeat the purpose of the patch.  Perhaps we could, allow a
>> > sensible max... (but this max is already being controlled as described).
>>
>> Any new max which is truly sensible, could be the new default, and we
>> would apply the same amount of vetting for such a thing.
>
>
> We have in linux a very conservative and complex rwin control at the
> beginning of a TCP session, only for the very first packets,
> if applications are reasonably fast at draining their receive queue.
> (They mostly are)
>
> Last time I had to take a look (after truesize changes), I was kind of
> worried to not find a good reason why we were doing this.
>
> We now have :
>
> - rcvbuf autotuning, letting rwin growing up to 3MB or so
> - Better truesize tracking
> - global/cgroup tcp mem accounting/pressure
> - TCP coalescing to minimize the effect of bad citizen packets
>     (very low len/truesize ratio)
> - People tracking TCP stack inefficiencies and working on new CCs...
>    (An example is Joe Touch I-D
> http://tools.ietf.org/html/draft-touch-tcpm-automatic-iw-03 that
> proposes increasing IW over a longer period of time (as opposed to
> revisiting constants every few years).
> - ...
>
> TCP congestion control is controlled by the sender, driven by the ACK
> coming back from receiver, and initial rwin should not change CC at all,
> unless we deliberately constrain rwin to a too small value.
>
> We did the 3 -> 10 change only two years ago.
> And 3 was really too small even 5 years ago.
>
> Browsers had to open simultaneous sessions to the same server only to
> workaround this limit, and they still do.
>
> I would just remove the 10 'hard constant', (but not so hard, since it
> was 3 only 2 years ago), and let tcp_rmem[1]/SO_RCVBUF decide of the
> initial receive window.
I like this idea a lot. Got a patch for us to try?

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
