From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP connection issues against Amazon S3
Date: Tue, 06 Jan 2015 11:16:27 -0800
Message-ID: <54AC348B.4030900@hp.com>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com> <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no> <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com> <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>, Erik Grinaker <erik@bengler.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:58164 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbbAFTQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:16:29 -0500
In-Reply-To: <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>>> A packet dump [1] shows repeated ACK retransmits for some of the
> TCP does not retransmit ACK ... do you mean DUPACKs sent by the receiver?
>
> I am trying to understand the problem. Could you confirm that it's the
> HTTP responses sent from Amazon S3 got stalled, or HTTP requests sent
> from the receiver (your host)?
>
> btw I suspect some middleboxes are stripping SACKOK options from your
> SYNs (or Amazon SYN-ACKs) assuming Amazon supports SACK.

The TCP Timestamp option too it seems.

Speaking of middleboxes...  It is probably a fish that is red, but a 
while back I stepped in a middle box (a load balancer) which decided 
that if it saw "too many" retransmissions in a given TCP window that 
something was seriously wrong and it would toast the connection.  I 
thought though that was an active reset on the part of the middlebox. 
(And the client was the active sender not the back-end server)

I'm assuming one incident starts at XX:41:24.748265 in the trace?  That 
does look like it is slowly slogging its way through a bunch of lost 
traffic, which was I think part of the problem I was seeing with the 
middlebox I stepped in, but I don't think I see the reset where I would 
have expected it.  Still, it looks like the sender has an increasing TCP 
RTO as it is going through the slog (as it likely must since there are 
no TCP timestamps?), to the point it gets larger than I'm guessing curl 
was willing to wait, so the FIN at XX:41:53.269534 after a ten second or 
so gap.

rick jones
