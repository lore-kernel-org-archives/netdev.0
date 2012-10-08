From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Mon, 8 Oct 2012 10:07:43 -0400
Message-ID: <20121008140743.GC22939@hmsreliant.think-freely.org>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
 <20120927142334.GA3194@neilslaptop.think-freely.org>
 <1348813987.7264.41.camel@cr0>
 <20120928131642.GA31568@hmsreliant.think-freely.org>
 <1349161479.22107.17.camel@cr0>
 <20121002120927.GA691@hmsreliant.think-freely.org>
 <1349666257.2707.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33932 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab2JHOH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 10:07:57 -0400
Content-Disposition: inline
In-Reply-To: <1349666257.2707.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 08, 2012 at 11:17:37AM +0800, Cong Wang wrote:
> On Tue, 2012-10-02 at 08:09 -0400, Neil Horman wrote:
> > No, its not very friendly, but the people using this are violating the RFC,
> > which isn't very friendly. :)
> 
> Could you be more specific? In RFC 793, AFAIK, it is allowed to be
> changed:
> 
> http://tools.ietf.org/html/rfc793
> 
> " To be sure that a TCP does not create a segment that carries a
>   sequence number which may be duplicated by an old segment remaining in
>   the network, the TCP must keep quiet for a maximum segment lifetime
>   (MSL) before assigning any sequence numbers upon starting up or
>   recovering from a crash in which memory of sequence numbers in use was
>   lost.  For this specification the MSL is taken to be 2 minutes.  This
>   is an engineering choice, and may be changed if experience indicates
>   it is desirable to do so."
> 
Its the length of time that represents an MSL that was the choice, not the fact
that reusing a TCP before the expiration of the MSL is a bad idea.

> or I must still be missing something here... :)
> 
Next paragraph down:
	This specification provides that hosts which "crash" without
    retaining any knowledge of the last sequence numbers transmitted on
    each active (i.e., not closed) connection shall delay emitting any
    TCP segments for at least the agreed Maximum Segment Lifetime (MSL)
    in the internet system of which the host is a part.  In the
    paragraphs below, an explanation for this specification is given.
    TCP implementors may violate the "quiet time" restriction, but only
    at the risk of causing some old data to be accepted as new or new
    data rejected as old duplicated by some receivers in the internet
    system. .... etc.
