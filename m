From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/2] Support outside netns for tunnels.
Date: Tue, 5 Jan 2016 17:47:09 +0100
Message-ID: <568BF38D.4060803@6wind.com>
References: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Saurabh Mohan <saurabh@cplanenetworks.com>, netdev@vger.kernel.org,
	stephen@networkplumber.org, davem@davemloft.net,
	pshelar@nicira.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38483 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbcAEQr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 11:47:28 -0500
Received: by mail-wm0-f43.google.com with SMTP id b14so38090749wmb.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 08:47:27 -0800 (PST)
In-Reply-To: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/01/2016 19:45, Saurabh Mohan a =C3=A9crit :
>
> This patch enchances a tunnel interface, like gre, to have the tunnel
> encap/decap be in the context of a network namespace that is differen=
t from
> the namespace of the tunnel interface.
>
>  From userspace this feature may be configured using the new 'onetns'=
 keyword:
> ip netns exec custa ip link add dev tun1 type gre local 10.0.0.1 \
>   remote 10.0.0.2 onetns outside
>
> In the above example the tunnel would be in the 'custa' namespace and=
 the
> tunnel endpoints would be in the 'outside' namespace.
What is the difference with the following commands?

ip netns exec outside ip link add dev tun1 type gre local 10.0.0.1 \
    remote 10.0.0.2
ip netns exec outside ip link set tun1 netns custa

or

ip exec custa ip netns set outside 1234
ip exec custa ip link add tun1 link-netnsid 1234 type gre local 10.0.0.=
1 \
    remote 10.0.0.2


Regards,
Nicolas
