From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 19/29] net: vrf: Add vrf context to skb
Date: Thu, 05 Feb 2015 18:21:58 -0700
Message-ID: <54D41736.9000507@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-20-git-send-email-dsahern@gmail.com> <54D37414.104@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:53237 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbbBFBWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 20:22:00 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so9782757iga.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 17:21:59 -0800 (PST)
In-Reply-To: <54D37414.104@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 6:45 AM, Nicolas Dichtel wrote:
> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
>> On ingress skb's inherit vrf context from the net_device. For TX skb=
's
>> inherit the vrf context from the socket originating the packet. Upda=
te
>> SKB related net_ctx macros to set vrf.
> Is it really needed to have this skb->vrf?
> Is it not possible to get the vrf from sockets, interfaces, etc? Like
> it's done
> with netns?

One reason is for VRF_ANY context of sockets.
Another one is netlink messages getting funneled through a single kerne=
l=20
netlink socket; skb->vrf is used to retain vrf handling.

in time might be able to make it go away.
