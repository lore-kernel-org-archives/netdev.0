From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with IFLA_NET_NS_[PID|FD]
Date: Thu, 05 Feb 2015 15:34:57 +0100
Message-ID: <54D37F91.4010500@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com> <54CBE2EF.7050003@alten.se> <54CF9EA8.4080207@6wind.com> <54D28237.9060009@alten.se>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dmitry.tarnyagin@lockless.no,
	alex.aring@gmail.com, linux-wpan@vger.kernel.org
To: Arvid Brodin <arvid.brodin@alten.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:48551 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757595AbbBEOfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:35:00 -0500
Received: by mail-we0-f176.google.com with SMTP id w62so8023169wes.7
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:34:59 -0800 (PST)
In-Reply-To: <54D28237.9060009@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/02/2015 21:33, Arvid Brodin a =C3=A9crit :
> On 2015-02-02 16:58, Nicolas Dichtel wrote:
>> Le 30/01/2015 21:00, Arvid Brodin a =C3=A9crit :
>>> On 2015-01-26 22:28, Nicolas Dichtel wrote:
[snip]
> Ok, so x-netns simply means cross-netns?
Yes
>
[snip]
>> Now, the question is: does HSR really work across netns? Why is the =
flag
>> NETIF_F_NETNS_LOCAL set?
>> dev_forward_skb() may be used to forward an skbuff to another netns.
>
> Here is the code snippet that sets NETIF_F_NETNS_LOCAL:
> 	/* Not sure about this. Taken from bridge code. netdev_features.h sa=
ys
> 	 * it means "Does not change network namespaces".
> 	 */
> 	dev->features |=3D NETIF_F_NETNS_LOCAL;
>
> HSR is a bit like a bridge since it forwards packets between interfac=
es on the
> same Ethernet network, and the bridge code sets NETIF_F_NETNS_LOCAL. =
And that's
> really all the reason for the inclusion of the flag - i.e. it should =
be removed
> if it doesn't make sense.
>
> So, does it make sense? I'm not sure exactly, but I don't think it ma=
kes sense
> to have slaves that are in different namespaces - they are supposed t=
o be part
> of the same ethernet network after all. But maybe having the HSR inte=
rface in a
> different namespace than the two slaves could make sense - this way y=
ou could
> force an application to only communicate using the HSR protocol, and =
not use any
> of the slave interfaces directly.
>
> If you agree with the above, then I guess that means NETIF_F_NETNS_LO=
CAL should
> not be set?
It's ok for me. But I think some tests should be done. Usually,
dev_forward_skb() or skb_scrub_packet() are called to clean structures =
when a
skb crosses netns.
