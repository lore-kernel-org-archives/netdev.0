From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Fri, 17 Jul 2009 11:05:58 -0700
Message-ID: <65634d660907171105s4989758ah533203d107924b6a@mail.gmail.com>
References: <65634d660907131504u35154059m5934cca3cb9363e0@mail.gmail.com>
	 <20090714.123313.186658126.davem@davemloft.net>
	 <65634d660907141628g671812f9t4219cc8b6a493425@mail.gmail.com>
	 <20090716.194846.58845712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:4865 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757613AbZGQSGD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 14:06:03 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id n6HI60Gb002556
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 19:06:01 +0100
Received: from qw-out-2122.google.com (qwd5.prod.google.com [10.241.193.197])
	by wpaz29.hot.corp.google.com with ESMTP id n6HI5wu3026681
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 11:05:58 -0700
Received: by qw-out-2122.google.com with SMTP id 5so329247qwd.23
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 11:05:58 -0700 (PDT)
In-Reply-To: <20090716.194846.58845712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2009 at 7:48 PM, David Miller <davem@davemloft.net> wro=
te:
>
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 14 Jul 2009 16:28:01 -0700
>
> > Using the Toeplitz hash in steering lookup has given us about 10% m=
ore
> > maximum pps (2 different NICs), and we haven't really noticed negat=
ive
> > effects because of the extra descriptor overhead-- so I'm not going=
 to
> > give up on it too easily!
>
> Do you have any idea why? =A0Does Toeplitz distribute better?
> If so, that could be merely because either:
>
> 1) Our modulus avoidance scheme somehow decreases the distribution
> =A0 features of the hash
>
> 2) The way we feed data into the hash has a similar effect
>
> It's worth checking out.

The advantage is that Toeplitz, or any reasonable device provided
hash, allows packet steering to be done without taking any cache
misses on the packet itself.=A0 In particular, this helps with a NIC
that just provides Toeplitz hash (without multiQ),
