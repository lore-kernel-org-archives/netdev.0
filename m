From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 02:03:37 -0700
Message-ID: <1502355817.4936.9.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170809104202.30959-1-vkuznets@redhat.com>
         <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
         <87efskye74.fsf@vitty.brq.redhat.com> <20170809161027.GA28694@lunn.ch>
         <871sojyfv0.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33658 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdHJJDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 05:03:41 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so2257776wmd.0
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 02:03:40 -0700 (PDT)
In-Reply-To: <871sojyfv0.fsf@vitty.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-10 at 10:41 +0200, Vitaly Kuznetsov wrote:
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> I understand the 'legacy' concern but at the same time we don't want to
> >> have aftificial limitations too. Name change, in particular, doesn't
> >> happen 'under the hood' -- someone privileged enough needs to request
> >> the change.
> >> 
> >> Can you think of any particular real world scenarios which are broken by
> >> the change?
> >
> > How about:
> >
> > man 8 dhclient-script
> >
> > The interface name is passed in $interface to the scripts. Do we get
> > the old name or the new name? I suspect scripts are going to break if
> > they are given the old name, which no longer exists.
> 
> Yes but why would anyone change interface name while dhclient-script is
> running? Things will also go wrong if you try bringing interface down
> during the run or do some other configuration, right? Running multiple
> configuration tools at the same moment is a bad idea, you never know
> what you're gonna end up with. 
> 
> As I see it, checks in kernel we have are meant to protect kernel
> itself, not to disallow all user<->kernel interactions leading to
> imperfect result.
> 
> (AFAIU) If we remove the check nothing is going to change: udev will
> still be renaming interfaces before bringing them up. In netvsc case
> users are not supposed to configure the VF interface at all, it just
> becomes a slave of netvsc interface.

Are we sending an event if device name is changed ?

If yes, your patch is fine.

If not, daemons would not be aware the need to refresh their view of the
world.
