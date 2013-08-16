From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/3 v4] ipv6: do not disable temp_address when reaching max_address
Date: Fri, 16 Aug 2013 13:07:38 +0200
Message-ID: <20130816110738.GC2112@order.stressinduktion.org>
References: <520B48AE.8050103@huawei.com> <20130814101511.GC16264@order.stressinduktion.org> <520C241A.2030708@huawei.com> <20130815012457.GD13066@order.stressinduktion.org> <520C3A13.3060106@huawei.com> <20130815173603.GA30746@order.stressinduktion.org> <20130815190754.GB30746@order.stressinduktion.org> <520D76EC.6000205@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, kargig@void.gr,
	ppandit@redhat.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55651 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178Ab3HPLHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 07:07:39 -0400
Content-Disposition: inline
In-Reply-To: <520D76EC.6000205@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 16, 2013 at 08:48:44AM +0800, Ding Tianhong wrote:
> On 2013/8/16 3:07, Hannes Frederic Sowa wrote:
> > On Thu, Aug 15, 2013 at 07:36:03PM +0200, Hannes Frederic Sowa wrote:
> >> Now we have to check why these addresses don't go out of tentative state.
> > 
> > Just looked at it. flood_router26 just emits pretty high values for
> > RetransTime:
> > 
> > 21:05:52.050159 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 192) fe80::c:2a47:1360:1101 > ff02::1: [icmp6 sum ok] ICMP6, router advertisement, length 192
> >         hop limit 255, Flags [none], pref high, router lifetime 65535s, reachable time 16384000ms, retrans time 1966080ms
> >           mtu option (5), length 8 (1):  1500
> >             0x0000:  0000 0000 05dc
> > 
> > We are completly in spec here. Just DAD needs a lot of time to finish.
> > 
> > Greetings,
> > 
> >   Hannes
> > 
> > 
> Great job, more and more close to the truth, let's find a better way to finish it. 

Thanks! :)

I just sent out a patch with the removal of the max_addresses
check. Please have a look!

I tested it with flood_router26 and modified it to also change the
retrans_time, because it affects in which interval addresses get
regenerated. We always were on the safe side.

Greetings,

  Hannes
