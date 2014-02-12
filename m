From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 16:43:22 +0100
Message-ID: <52FB969A.607@6wind.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:53875 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbaBLPn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 10:43:28 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so3914328ead.38
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 07:43:27 -0800 (PST)
In-Reply-To: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/02/2014 00:51, Cong Wang a =C3=A9crit :
> From: Cong Wang <cwang@twopensource.com>
>
> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=3D66691
>
> macvlan and vlan both use iflink to identify its lower device,
> however, after such device is moved to the new netns, its iflink
> would become meaningless as ifindex is per netns. So, instead of
> forbid them moving to another netns, just clear this field so that
> it will not be dumped at least.
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
I wonder if this patch breaks things in ip tunnels.
=46or example, ip6_tunnel uses iflink to find tunnels that are bound to=
 an interface.
If you reset this field, ipip6_tunnel_lookup() will fail when the tunne=
l moves
to another netns.
