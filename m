From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 21:45:12 +0100
Message-ID: <1445892312.1018239.420827817.3EC76081@webmail.messagingengine.com>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
 <562E4C26.3030501@gmail.com>
 <1445877236.175039.420582401.131556D5@webmail.messagingengine.com>
 <9831.1445887009@famine>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:54552 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136AbbJZUpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 16:45:13 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id A97AE20A17
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 16:45:12 -0400 (EDT)
In-Reply-To: <9831.1445887009@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Oct 26, 2015, at 20:16, Jay Vosburgh wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> >Hello Alex,
> >
> >On Mon, Oct 26, 2015, at 16:52, Alexander Duyck wrote:
> >> Seems like this code isn't quite correct.  You are calling ipv6_add_dev 
> >> for slave devices, and if I understand things correctly I don't believe 
> >> that was happening before and may be an unintended side effect.
> >
> >Ah, btw., autoconf and ipv6 operation on IFF_SLAVE devices is actually
> >desired nowadays and don't think we can change this. See also:
> ><https://patchwork.ozlabs.org/patch/531196/>
> 
> 	IPv6 addrconf on IFF_SLAVE devices was disabled for bonding
> slaves in commit c2edacf80e15 because it caused issues with snooping
> switches.
> 
> 	This is also referenced in
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=236750
> 
> 	Won't re-enabling autoconf on IFF_SLAVE devices cause that issue
> to return?

Both patches don't enable autoconf on IFF_SLAVE devices. Sorry for being
imprecise. The referred patch was changing the behavior to whether the
device had a master device.

@Alex, I will take your patch and submit it with the necessary guards to
not enable ipv6 again if we forcefully disable ipv6 and later on shrink
and increase the MTU again. I will do so in your name. Thanks again for
the patch!

Bye,
Hannes
