From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 18:38:58 -0700
Message-ID: <1364521138.15753.66.camel@edumazet-glaptop>
References: <20130328150410.GA22789@sergelap>
	 <CD7A1D9A.78BA%blourdel@juniper.net>
	 <20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
	 <87zjxn84ks.fsf@xmission.com> <1364516016.15753.59.camel@edumazet-glaptop>
	 <87ppyj6ohh.fsf@xmission.com> <1364517837.15753.61.camel@edumazet-glaptop>
	 <1364519448.15753.63.camel@edumazet-glaptop> <87wqsr3sf2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:52396 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab3C2BjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 21:39:07 -0400
Received: by mail-pd0-f179.google.com with SMTP id x11so55676pdj.38
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 18:39:06 -0700 (PDT)
In-Reply-To: <87wqsr3sf2.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 18:29 -0700, Eric W. Biederman wrote:

> An interesting thought.  I had a patch I never got around to pushing a
> while back that would have had an effect.
> 
> It is my observation that the vast majority of packet filters apply not
> to the entire machine but to an individual interface.  In fact you have
> to work pretty hard to get tools like tcpdump to dump all of the
> interfaces at once.
> 
> So to speed things up for machines that have a lot of these things the
> idea was to create per device lists for the filters that only needed to
> be run on a single device.  In this case it looks like we could
> potentially create per device lists for of the listening sockets as well.
> 
> In general these lists should be short so the search can also be short.
> 
> But I am curious do you actually have a tcpdump or something similar
> running on your box that is using AF_PACKET sockets?  Perhaps a dhcp
> client?
> 
> I am a little surprised that your default case has anything on the lists
> to trigger any work in the packet_notifier notifier.

Hmm, it might be a local daemon on my lab machine which does a
PACKET_ADD_MEMBERSHIP for each created interface.

So my machine spend time in packet_dev_mclist(), with a quadratic
behavior at rmmod.
