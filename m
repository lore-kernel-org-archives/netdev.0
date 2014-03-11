From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 1/2] netpoll:  Remove dead netpoll_rx code
Date: Tue, 11 Mar 2014 13:48:01 -0700
Message-ID: <87eh28cvi6.fsf@xmission.com>
References: <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com> <8738ipf7kn.fsf_-_@xmission.com>
	<1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48503 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416AbaCKUsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:48:10 -0400
In-Reply-To: <20140311082312.5ad00119@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Tue, 11 Mar 2014 08:23:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue, 11 Mar 2014 05:29:21 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> On Tue, 2014-03-11 at 01:44 -0700, Eric W. Biederman wrote:
>> > The netpoll_rx code only becomes active if the netpoll rx_skb_hook is
>> > implemented.  There is not a single implementation of the netpoll
>> > rx_skb_hook in the kernel.
>> > 
>> > There are problems with the netpoll packet receive code. Most
>> > speifically every packet that makes it to netpoll_neigh_reply is
>> > leaked.
>> > 
>> > Given that the netpoll packet receive code is buggy and has not been used
>> > for a decade let's just remove it.
>> > 
>> > Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> > ---
>> >  drivers/net/Kconfig       |    5 -
>> >  include/linux/netdevice.h |   17 --
>> >  include/linux/netpoll.h   |   59 ------
>> >  net/core/dev.c            |   11 +-
>> >  net/core/netpoll.c        |  471 ---------------------------------------------
>> >  5 files changed, 1 insertions(+), 562 deletions(-)
>> 
>> I cannot agree more, thanks Eric.
>> 
>> Acked-by: Eric Dumazet <edumazet@google.com>
>
> I agree but removing it breaks people trying to kgdb over network (kgdboe).
> That code never made it upstream, was unreliable and fragile and should be
> sent to the retirement home with IMQ.

To play devil's advocate to my own patch.  Does anyone know where kgdb
over network (kgdboe) code lives today?

What little I could find in a quick google search strongly suggests that
kgdboe was abandoned in 2010 or so.

I am trying to figure out if there are any active out of tree projects
that need by directional netpoll.

Eric
