From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Wed, 25 Mar 2015 13:47:17 -0500
Message-ID: <1427309237.31633.24.camel@redhat.com>
References: <20150324180628.278017fb@griffin>
	 <CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
	 <20150325095851.1d8d1622@griffin>
	 <20150325.114622.1915164845375005128.davem@davemloft.net>
	 <CAF2d9jh5WaNYsMxp29GY3LqM08jjVPwLd1BQ1HLFKMsKFda6zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jbenc@redhat.com,
	linux-netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbbCYSrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 14:47:18 -0400
In-Reply-To: <CAF2d9jh5WaNYsMxp29GY3LqM08jjVPwLd1BQ1HLFKMsKFda6zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-25 at 11:11 -0700, Mahesh Bandewar wrote:
> On Wed, Mar 25, 2015 at 8:46 AM, David Miller <davem@davemloft.net> wrote:
> > From: Jiri Benc <jbenc@redhat.com>
> > Date: Wed, 25 Mar 2015 09:58:51 +0100
> >
> >> On Tue, 24 Mar 2015 16:16:38 -0700, Mahesh Bandewar wrote:
> >>> Well, we already have hlist_unhashed().The following patch should fix
> >>> the duplicate addition as well as deletion. Please give it a try.
> >>
> >> Good idea, it's surely better than adding a new boolean.
> >>
> >> However, I'm wondering that when there's apparently no problem with the
> >> addresses being on the hash list when interface is down, what's the
> >> point in clearing the hash list in the ndo_stop handler and
> >> repopulating it in ndo_open?
> >>
> >> The following patch fixes the problem, too, and as a bonus removes code:
> >
> > I'll let Mahesh reply to this.
> 
> Yes functionally you will get the same result. However during the RX
> processing, that code helps ipvlan-demux machine along with
> packet-dispatcher to determine it early to drop the packet rather than
> later. Also note that addition / deletion of address entries in
> hash-table is done in control-path while the demux / dispatcher
> operate in data-path. So for this reason I would prefer to leave the
> hash-table entries addition / deletion as it is.

Jiri's patch was actually prompted by my testing of ipvlan with L2 mode.
How much testing of L2 have you given ipvlan internally and what setups
have you tested?  It doesn't look like ipvlan handles ARP/ICMP very well
at all right now, and while I've got patches to fix some of that I'm
trying to characterize the rest.  Also, have you ever tested it with
DHCP?

Dan
