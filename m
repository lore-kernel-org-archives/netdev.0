From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RTM_NEWLINK not received by application when connecting
 multiple devices simultaneously
Date: Thu, 19 Apr 2012 07:54:52 -0700
Message-ID: <20120419075452.379f711b@s6510.linuxnetplumber.net>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45600 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754510Ab2DSOzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 10:55:00 -0400
In-Reply-To: <4F90208E.6070201@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Apr 2012 07:26:22 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 04/19/2012 04:44 AM, Kristian Evensen wrote:
> > Hello,
> 
> > The application works as intended when I connect interfaces one by
> > one. However, if I connect two interfaces "simultaneously", the
> > RTM_NEWLINK message for one of the interfaces is sometimes not
> > received. Nothing arrives at the handle. It seems to be random which
> > RTM_NEWLINK actually arrives. I have only been able to recreate this
> > problem when connecting two USB 3G modems and automatically dialing
> > the ISP, but I assume it would happen with other technologies as well.
> > What puzzles me, is that both RTM_NEWLINK messages are seen by for
> > example ip monitor. This has led me to conclusion that there is a bug
> > in my application, and my question is therefore, are there any common
> > mistakes one can make or things to forget that would cause a message
> > to get lost or not be received, or does anyone have any tips on where
> > I can start looking?
> 
> Multiple netlink msgs can be received in each read of a netlink
> socket.  Maybe you are only processing the first one?

I recommend using the libmnl library instead of the older
libnetlink. The code is cleaner and it handles error cases better.
In libmnl there is a callback interface for parsing
netlink messages.
