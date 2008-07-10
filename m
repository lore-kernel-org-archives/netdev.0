From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 14:05:20 -0700
Message-ID: <1e41a3230807101405y437dff4er443185be3228caa5@mail.gmail.com>
References: <4876668C.8040108@limebrokerage.com> <48766CF0.1020101@hp.com>
	 <48766EC2.2090000@limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rick Jones" <rick.jones2@hp.com>, netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?Dan_No=E9?=" <dnoe@limebrokerage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:51799 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbYGJVFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 17:05:22 -0400
Received: by an-out-0708.google.com with SMTP id d40so717971and.103
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 14:05:21 -0700 (PDT)
In-Reply-To: <48766EC2.2090000@limebrokerage.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 1:19 PM, Dan No=E9 <dnoe@limebrokerage.com> wro=
te:
> Rick Jones wrote:
>>
>> If this is just for troubleshooting, why not just take a tcpdump tra=
ce?
>
> We're pushing a lot of data.. several Mbps pretty much all day long..=
 and
> the (suspected) loss occurs sporadically.  Ideally we'd like to be ab=
le to
> easily correlate it with latency seen in our app.


Looking for loss at the receiver is a bit tricky.  It doesn't look
like struct tcp_info has enough information to do this easily.  If you
are able to install a custom kernel on this machine, the Web100 patch
would be able to gather enough information to figure it out.  The
basic idea would be to look for a difference between RcvNxt and
RcvMax.

On the other hand, several Mbps is not that much.  It's probably not
that hard to take tcpdumps split up every N minutes, and analyze
these.  One thing to look for would be sack blocks coming from the
receiver (assuming sack is enabled.)

  -John
