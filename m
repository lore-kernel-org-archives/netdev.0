From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] TCP: Add seq and ack numbers to TCP_INFO
Date: Wed, 9 Jul 2008 11:02:54 -0700
Message-ID: <396556a20807091102n5bb061daw91f41512faa8474@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe069003@europa>
	 <20080709104934.390cd81b@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:1068 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbYGISCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 14:02:55 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3649018rvb.1
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 11:02:54 -0700 (PDT)
In-Reply-To: <20080709104934.390cd81b@speedy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 9, 2008 at 10:49 AM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
> Of what possible use is this to an application? I worry that applications would
> come to expect or use certain characteristics of the network and TCP which
> would be broken by later changes.

Well, when you consider what else is in tcp_info (window scaling, SACK
info, MTU, RTT, reorder detection), the sequence numbers seem
positively pedestrian.

There are a bunch of crazy reasons why userspace might be interested
in the seq/ack numbers: handing connections between hosts, checking
the backlog, analyzing the RNG strength of remote hosts etc. All
experimental crap to be sure, but it's very handy in those
experiments. I used a very similar patch when doing some of the very
early basic on backlogs that Jerry Chu has taken up now.

And sequence numbers are pretty fundamental to TCP. Certainly much
more so than much of the other stuff that we're currently happy to
export with sufficient warnings.


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
