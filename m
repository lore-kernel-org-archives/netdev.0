From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC patch net-next] ipv4: use bcast as dst address in case IFF_NOARP is set
Date: Tue, 08 Jan 2013 11:10:33 -0800 (PST)
Message-ID: <0355baea-4761-477b-a68a-cd40fd5033b8@tahiti.vyatta.com>
References: <20130108174538.GC1621@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, pavlix@pavlix.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41843 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756889Ab3AHTKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 14:10:34 -0500
In-Reply-To: <20130108174538.GC1621@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Tue, Jan 08, 2013 at 06:11:55PM CET, stephen.hemminger@vyatta.com
> wrote:
> >
> >> When IFF_NOARP is set on a device, dev->dev_addr is used as *dst*
> >> addr of sent frames. That does not make sense. Use rather bcast
> >> address
> >> instead.
> >> 
> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >
> >What did you test this on? I think this may have been
> >intentional to avoid broadcasting.
> 
> Thanks for looking at this Stephen.
> 
> I tested this on two boxes connected via ethernet.
> 
> I believe this may have been intentional, but what sense does it have
> to
> use dev_addr as destination address? That is what I do not
> understand.
> 
> Also, what is the issue with sending all packets to broadcast when
> NOARP is
> set? In my opinion, it only makes sense.
> 

It looks like NOARP devices are point-to-point and don't really
have any concept of broadcast.
