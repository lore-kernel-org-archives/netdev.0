From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] net: gre: don't pull skb if dealing with icmp message
Date: Mon, 20 Jan 2014 09:37:40 +0800
Message-ID: <52DC7DE4.1050108@cn.fujitsu.com>
References: <52DB8E4A.7050809@cn.fujitsu.com> <CALnjE+qtB4fEw4HdUZy6nXU6gSAjeSCiBn0EaQR9o_d2SY3yNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2956 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbaATBiX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 20:38:23 -0500
In-Reply-To: <CALnjE+qtB4fEw4HdUZy6nXU6gSAjeSCiBn0EaQR9o_d2SY3yNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B401=E6=9C=8820=E6=97=A5 05:08, Pravin Shelar =E5=86=
=99=E9=81=93:
> On Sun, Jan 19, 2014 at 12:35 AM, Duan Jiong <duanj.fnst@cn.fujitsu.c=
om> wrote:
>>
>> When dealing with icmp messages, the skb->data points the
>> ip header that triggered the sending of the icmp message.
>>
>> In gre_cisco_err(), the parse_gre_header() is called, and the
>> iptunnel_pull_header() is called to pull the skb at the end of
>> the parse_gre_header(). Unfortunately, the ipgre_err still needs
>> the skb->data points the ip header following the icmp layer,
>> and those ip addresses in ip header will be used to look up
>> tunnel by ip_tunnel_lookup().
>>
> This looks like bug.
> Can you use ip_hdr() rather than skb->data in ipgre_err().
> Same is done in ipgre_rcv().

That's maybe not a good idea. The ip_hdr() will the return the outmost
ip header, but we need inner ip header following the icmp layer.

Thanks,
  Duan

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
