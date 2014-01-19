From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] net: gre: don't pull skb if dealing with icmp message
Date: Sun, 19 Jan 2014 13:08:58 -0800
Message-ID: <CALnjE+qtB4fEw4HdUZy6nXU6gSAjeSCiBn0EaQR9o_d2SY3yNQ@mail.gmail.com>
References: <52DB8E4A.7050809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:46926 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752007AbaASVPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 16:15:38 -0500
Received: by mail-ie0-f176.google.com with SMTP id tp5so1148827ieb.7
        for <netdev@vger.kernel.org>; Sun, 19 Jan 2014 13:15:38 -0800 (PST)
In-Reply-To: <52DB8E4A.7050809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 19, 2014 at 12:35 AM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>
> When dealing with icmp messages, the skb->data points the
> ip header that triggered the sending of the icmp message.
>
> In gre_cisco_err(), the parse_gre_header() is called, and the
> iptunnel_pull_header() is called to pull the skb at the end of
> the parse_gre_header(). Unfortunately, the ipgre_err still needs
> the skb->data points the ip header following the icmp layer,
> and those ip addresses in ip header will be used to look up
> tunnel by ip_tunnel_lookup().
>
This looks like bug.
Can you use ip_hdr() rather than skb->data in ipgre_err().
Same is done in ipgre_rcv().
