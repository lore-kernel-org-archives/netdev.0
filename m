From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 13:06:11 -0700
Message-ID: <9E73042B-BF54-48FD-8755-C215FD03C9AE@earthlink.net>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jmatthews@greenplum.com,
	Tim Heath <theath@greenplum.com>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:47300 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754494Ab0F3UGV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 16:06:21 -0400
In-Reply-To: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 30, 2010, at 11:04 AM, Ivan Novick wrote:

> Hello all,
> 
> Attached is a packet capture from my application that is running on
> RedHat Enterprise Linux 5.4
> 
> I am seeing a Retransmission timeout but I was hoping this case would
> go into fast retransmit and not RTO.
> 
> I am wondering why did the sender not send more data?  If the sender
> was to send more data and extend the window then it would seem the
> duplicate acks or SACKS should trigger fast retransmit.
> 
> The application does not constantly send data, but data should arrive
> to be sent before 200 milliseconds that it takes for the RTO.
> 
> Is it possible that there was no data to send and the window is not
> advanced and the sender is waiting for an ACK.  Then data arrives half
> way into the RTO 200 milliseconds while waiting for an outstanding ACK
> but the window is not advanced?
> 
> You can see right after the RTO and retransmission additional data is
> sent, so there is additional data.  In theory that additional data
> could be arriving right at the 200 milliseconds point, but we see this
> pattern in the dump regularly and I believe data is there before the
> end of the 200 milliseconds RTO.
> 
> As a related point the advertised window from the receiver seems to be
> a constant value of 22060, so either the receiver is handling its data
> fast enough to never have to reduce its window... or this number is
> really not used to indicate space available currently in the receive
> window?
> 
> Any feedback to help understand why we are not doing fast retransmit
> and or why the sender is not extending the window would be greatly
> appreciated.
> 
> Cheers,
> Ivan Novick
> <sender_backoff.cap>

Ivan, et al,

Without looking at your dump, not getting DUPAcks then
- their isn't enough in-flight data/ segments to generate enough ACKs (Duplicate ACKs)
assuming you get ACKs with non-increasing SEQs
- or the/some ACKs are being dropped.

Normally to fix this is to set the MTU / MSS size to say 576 at the two
end points if this is re-runnable, OR make it a thin flow

With a real quick look at your dump, 

my first question is why the .1 -> .2 always has a small window of 46
one way data transfer?

Now, taking a look at the dump with a -r ,
What makes you think that DupACKs are being sent?
To then cause a Fast Re-transmit?

Sometimes, adding tracing within the tcps, can identify if.
the tcp flow has periods of idleness,
the tcp flow is/has been application limited versus network limited,
whether the flow is in SS or CA?
CA normally has DELayed ACks, which reduces the number 
    of ACKs to 1/2 or more,
Whether Fast re-xmit is triggered by 2 or 3 DupAcks.
whether any burst avoidance has occured,
etc,


Mitchell Erblich







