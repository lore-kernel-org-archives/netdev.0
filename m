From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] wireless, ipv4, ipv6: drop GTK-protected unicast IP
 packets
Date: Thu, 21 Nov 2013 15:31:04 +0100
Message-ID: <1385044264.14273.6.camel@jlt4.sipsolutions.net>
References: <1385039154-20637-1-git-send-email-johannes@sipsolutions.net>
	 (sfid-20131121_140611_855342_F7C001E6) <1385039307.14273.4.camel@jlt4.sipsolutions.net>
	 <1385043867.10637.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 (sfid-20131121_152431_763108_248DD4C9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Jouni Malinen <jouni@qca.qualcomm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50315 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab3KUObJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 09:31:09 -0500
In-Reply-To: <1385043867.10637.39.camel@edumazet-glaptop2.roam.corp.google.com> (sfid-20131121_152431_763108_248DD4C9)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 06:24 -0800, Eric Dumazet wrote:
> On Thu, 2013-11-21 at 14:08 +0100, Johannes Berg wrote:
> > On Thu, 2013-11-21 at 14:05 +0100, Johannes Berg wrote:
> > 
> > > @@ -498,7 +500,8 @@ struct sk_buff {
> > >  	 * headers if needed
> > >  	 */
> > >  	__u8			encapsulation:1;
> > > -	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
> > > +	__u8			drop_unicast:1;
> > 
> > The obvious question is here, and for IPv4/IPv6 - should the wireless
> > stack be responsible for doing this instead?
> 
> I don't really like the idea of reserving a bit for this in sk_buff,
> and propagate it in every cloning ...
> 
> Someone should replace __copy_skb_header() by a single memset(),
> because copying all these bits one by one is not really clever.
> 
> And then, adding a test in fast path (ip_rcv_finish()) is really not
> nice.

Yeah, that was a concern too. I'll do it entirely in the wireless stack
instead I guess. At least it'll be hidden away inside the if that
already does the group key check etc.

Thanks.

johannes
