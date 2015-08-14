From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG net-next] infamous dev refcnt leak... again.
Date: Fri, 14 Aug 2015 16:31:32 -0700
Message-ID: <1439595092.7507.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439586894.7507.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439594063.7507.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55CE7776.5000706@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34107 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbbHNXbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 19:31:33 -0400
Received: by pdbfa8 with SMTP id fa8so35594302pdb.1
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 16:31:33 -0700 (PDT)
In-Reply-To: <55CE7776.5000706@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-14 at 17:19 -0600, David Ahern wrote:
> On 8/14/15 5:14 PM, Eric Dumazet wrote:
> > On Fri, 2015-08-14 at 14:14 -0700, Eric Dumazet wrote:
> >> While rebooting host running latest net-next
> >>
> >>   unregister_netdevice: waiting for eth0 to become free. Usage count = 4
> >>
> >> Oh well...
> >>
> >
> > It looks like David Ahern recent changes uncover a bug ?
> >
> > Not clear which commit is at fault.
> >
> > Maybe 3bfd847203c6d89532f836ad3f5b4ff4ced26dd9 ?
> >
> > Somehow a down device can be found.
> 
> Can you elaborate on what you are doing to see the refcnt leak? I have 
> not seen that at all. I have to leave for soccer carpool in 45 minutes 
> or so, but can take a look this weekend.


I simply reboot my host. eth0 device can not be dismantled and block the
reboot, I gave to reset the host.

I get the issue every time.

I confirm reverting 3bfd847203c6d89532f836ad3f5b4ff4ced26dd9
removes the issue for me.
