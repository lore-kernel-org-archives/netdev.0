From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 1/2] udp: Do not require sock in udp_tunnel_xmit_skb
Date: Sat, 17 Jan 2015 15:45:36 -0800
Message-ID: <CAEP_g=_5_OCYMwBL0onvH0i+t9LxRqfrD5D7rLqFOUft7H8DzA@mail.gmail.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com> <1421518700-22460-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:49860 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751261AbbAQXp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 18:45:57 -0500
Received: by mail-qa0-f54.google.com with SMTP id w8so19129636qac.13
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 15:45:57 -0800 (PST)
In-Reply-To: <1421518700-22460-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 17, 2015 at 10:18 AM, Tom Herbert <therbert@google.com> wrote:
> The UDP tunnel transmit functions udp_tunnel_xmit_skb and
> udp_tunnel6_xmit_skb include a socket argument. The socket being
> passed to the functions (from VXLAN) is a UDP created for receive
> side. The only thing that the socket is used for in the transmit
> functions is to get the setting for checksum (enabled or zero).
> This patch removes the argument and and adds a nocheck argument
> for checksum setting. This eliminates the unnecessary dependency
> on a UDP socket for UDP tunnel transmit.
>
> Signed-off-by: Tom Herbert <therbert@google.com>

I think you need to update Geneve as well:

net/ipv4/geneve.c:139:38: warning: incorrect type in argument 1
(different base types)
net/ipv4/geneve.c:139:38:    expected struct rtable *rt
net/ipv4/geneve.c:139:38:    got struct socket *sock
net/ipv4/geneve.c:139:46: warning: incorrect type in argument 2
(different base types)
net/ipv4/geneve.c:139:46:    expected struct sk_buff *skb
net/ipv4/geneve.c:139:46:    got struct rtable *rt
net/ipv4/geneve.c:139:50: warning: incorrect type in argument 3
(different base types)
net/ipv4/geneve.c:139:50:    expected restricted __be32 [usertype] src
net/ipv4/geneve.c:139:50:    got struct sk_buff *[assigned] skb
net/ipv4/geneve.c:139:60: warning: incorrect type in argument 5
(different base types)
net/ipv4/geneve.c:139:60:    expected unsigned char [unsigned] [usertype] tos
net/ipv4/geneve.c:139:60:    got restricted __be32 [usertype] dst
net/ipv4/geneve.c:140:41: warning: incorrect type in argument 7
(different base types)
net/ipv4/geneve.c:140:41:    expected restricted __be16 [usertype] df
net/ipv4/geneve.c:140:41:    got unsigned char [unsigned] [usertype] ttl
net/ipv4/geneve.c:140:60: warning: incorrect type in argument 10
(different base types)
net/ipv4/geneve.c:140:60:    expected bool [unsigned] [usertype] xnet
net/ipv4/geneve.c:140:60:    got restricted __be16 [usertype] dst_port
