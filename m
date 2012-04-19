From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: RTM_NEWLINK not received by application when connecting multiple
 devices simultaneously
Date: Thu, 19 Apr 2012 21:54:24 +0200
Message-ID: <CAKfDRXhAqFzPWAJkzhPdZGsUrtjex8uVwHBynCdvA+Zo6sjMig@mail.gmail.com>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
	<20120419075452.379f711b@s6510.linuxnetplumber.net>
	<CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:33414 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756134Ab2DSTyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 15:54:25 -0400
Received: by yhmm54 with SMTP id m54so4762009yhm.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 12:54:24 -0700 (PDT)
In-Reply-To: <CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I spent some more time debugging this now. It turns out that which
interface is seen by my application is not random, it is always the
first one that is connected. This indicates that the bug is that the
netlink message contains information about more than one interface.
However, I am not able to prove this.

When I check for the presence of NLM_F_MULTI, it is always NULL. Also,
the length of the received nlmsg (including payload) always equals the
numbers of bytes I receive from the netlink socket, i.e., all the data
is received.

Based on my understanding of netlink, an nlmsg will only contain one
packet (for example ifinfomsg), unless the NLM_F_MULTI flag is set. Or
am I mistaken?

-Kristian
