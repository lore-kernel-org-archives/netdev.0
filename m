From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 1/4] net: ipv6: Introduce flowi6_init_output.
Date: Sun, 27 Apr 2014 13:03:09 +0900
Message-ID: <CAKD1Yr1EYAWEoQyAZWOKb0-YwkYP1tq8S+ywkk0=q9Hz+SfDtA@mail.gmail.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
 <1398487705-13430-2-git-send-email-lorenzo@google.com> <alpine.LFD.2.11.1404260850030.1554@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, JP Abgrall <jpa@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:64511 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbaD0EDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 00:03:30 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so3616051igq.13
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 21:03:29 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1404260850030.1554@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2014 at 2:56 PM, Julian Anastasov <ja@ssi.bg> wrote:
>> +     fl6->flowi6_oif = oif;
>> +     fl6->flowi6_iif = 0;
>
>         Make sure LOOPBACK_IFINDEX is provided in
> flowi6_iif instead of 0, recent commit fixed such
> FIB rule lookups.

I'm assuming that was for IPv4? All the IPv6 code in current net-next
still seems to set flowi6_iif to zero. It's later set to
LOOPBACK_IFINDEX in ip6_route_output.

You could argue that if this patch is accepted, then setting
flowi6_iif to LOOPBACK_IFINDEX belongs there for consistency with
IPv4. That seems reasonable, but I'd prefer not doing that in this
patch because 1) this patch is semantically a no-op and I'd like to
keep it that way, 2) it would be a bigger change, because even with
this patch, there are still codepaths that initialize their own flowi6
and memset them to zero.
