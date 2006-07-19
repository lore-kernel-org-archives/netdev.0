From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Wed, 19 Jul 2006 02:38:12 -0700
Message-ID: <7335583a0607190238x782a5c37pd4f62830e52ec65a@mail.gmail.com>
References: <44BD38B1.1080807@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:12670 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S964776AbWGSJiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 05:38:13 -0400
Received: by wr-out-0506.google.com with SMTP id i32so53922wra
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2006 02:38:13 -0700 (PDT)
To: "Oumer Teyeb" <oumer@kom.aau.dk>
In-Reply-To: <44BD38B1.1080807@kom.aau.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oumer,

    Your result is interesting. Just a few questions (along with your texts):

> So I looked further into the results, and what I found was that when
> SACK (when I refer to SACK here, I mean SACK only without FACK and
> DSACK)  is used, the retransmissions seem to happen earlier .
> at www.kom.auc.dk/~oumer/first_transmission_times.pdf
> you can find the pic of cdf of the time when the first TCP
> retransmission occured for the four combinations of SACK and timestamps
> after hundrends of downloads of a 100K file for the different conditions
> under network reordering...

Could you give a little bit more details on the scenarios. For example:
What is your RTT, capacity and etc? Linux versions? Packetsize is
1.5K? Then 100K is about 66 packets. Do flows finish slow start or
not? Also, what is the reordering level? Are you using Dummynet or
real network?


> ...but I couldnt figure out why the retransmissions occur earlier for
> SACK than no SACK TCP. As far as I know, for both SACK and non SACK
> cases, we need three (or more according to the setting) duplicate ACKs
> to enter the fast retransmission /recovery state.... which would have
> resulted in the same behaviour to the first occurance of a
> retransmission..... or is there some undocumented enhancment in Linux
> TCP when using SACK that makes it enter fast retransmit earlier... the
> ony explanation I could imagine is something like this

Are you sure FACK is turned OFF? FACK might retransmit earlier if you
have packet reordering, I think.


> non SACK case
> =============
> 1 2 3 4 5 6 7 8 9 10..... were sent and 2 was reorderd....and assume we
> are using delayed ACKs...and we get a triple duplicate ACK after pkt#8
> is received. (i.e 3&4--first duplicate ACK, 5&6..second duplicate ACK
> and 7&8...third duplicate ACK.....)...
>
> so if SACK behaved like this...
>
> 3&4 SACKEd.... 2 packets out of order received
> 5&6 SACKEd....4 packets out of order received.... start fast
> retransmission....as reorderd is greater than 3.... (this is true when
> it comes to marking packets as lost during fast recovery, but is it true
> als for the first retransmission?)

I guess delayed ACK is turned off when there is packet reordering. The
receiver will send one ack for each data packet whenever there is out
of order packets in its queue. So we will get duplicate ack ealier
than what you explain above...


> One more thing, say I have FRTO, DSACK and timestamps enabled, which
> algorithm takes precedence ? if FRTO is enabled, then all spurious
> timeout detection are done through FRTO or a combination?..

They are compatible, I think?

When retransmission timer times out, it first tries to go through
FRTO. If FRTO found it's a real loss, then it goes to traditional
timeout process as specified in FRTO algorithm.

-David

-- 
Xiaoliang (David) Wei      Graduate Student, CS@Caltech
http://davidwei.org
***********************************************
