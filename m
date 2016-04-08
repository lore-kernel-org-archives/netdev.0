From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: qdisc spin lock
Date: Fri, 08 Apr 2016 07:19:17 -0700
Message-ID: <1460125157.6473.434.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	 <CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
	 <CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36553 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcDHOT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 10:19:27 -0400
Received: by mail-io0-f178.google.com with SMTP id q128so133215133iof.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 07:19:26 -0700 (PDT)
In-Reply-To: <CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-31 at 16:48 -0700, Michael Ma wrote:
> I didn't really know that multiple qdiscs can be isolated using MQ so
> that each txq can be associated with a particular qdisc. Also we don't
> really have multiple interfaces...
> 
> With this MQ solution we'll still need to assign transmit queues to
> different classes by doing some math on the bandwidth limit if I
> understand correctly, which seems to be less convenient compared with
> a solution purely within HTB.
> 
> I assume that with this solution I can still share qdisc among
> multiple transmit queues - please let me know if this is not the case.

Note that this MQ + HTB thing works well, unless you use a bonding
device. (Or you need the MQ+HTB on the slaves, with no way of sharing
tokens between the slaves)


https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=bb1d912323d5dd50e1079e389f4e964be14f0ae3

bonding can not really be used as a true MQ device yet.

I might send a patch to disable this 'bonding feature' if no slave sets
a queue_id. 
