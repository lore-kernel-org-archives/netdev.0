From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about MAC address change
Date: Sun, 23 Dec 2007 15:04:37 +0200
Message-ID: <31436f4a0712230504x7b0b4f38i8f69a7a825bcc14b@mail.gmail.com>
References: <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com>
	 <20071223.211126.118866275.yoshfuji@linux-ipv6.org>
	 <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
	 <20071223.213841.108421688.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:47071 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbXLWNEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 08:04:38 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1941454wah.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 05:04:38 -0800 (PST)
In-Reply-To: <20071223.213841.108421688.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,


>You should iterate all of ifa_list (for IPv4) / addr_list (for IPv6).
> For IPv6, we also have anycast (maintained by ac_list) as well.

I am not sure that we need to iterate all of ifa_list in IPv4.
The reason is that we end with arp_send, and it initiates a broadcast.
So all neighbours will receive it and update their arp tables
accordingly.
The dest hw in the arp_send is NULL according to this patch ; this means that
we will assign dev->broadcast to dest_hw  in apr_create().

It seems to me there's no reason to send more than one broadcast.

In IPv6, I need to check, since it is multicast.

Thoughts ?

Regards,
DS





On Dec 23, 2007 2:38 PM, YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org> wrote:
> In article <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com> (at Sun, 23 Dec 2007 14:24:00 +0200), "David Shwatrz" <dshwatrz@gmail.com> says:
>
> > Regarding your answer;  I accept it and I will soon send a revised
> > version of this patch (making changes to
> >  arp_netdev_event() and ndisc_netdev_event().)
> > I had  IPv4 in mind, there is no reason that it will no be also in IPv6.
>
> You should iterate all of ifa_list (for IPv4) / addr_list (for IPv6).
> For IPv6, we also have anycast (maintained by ac_list) as well.
>
> --yoshfuji
>
>
