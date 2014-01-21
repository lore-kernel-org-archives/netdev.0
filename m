From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] net: gre: don't pull skb if dealing with icmp message
Date: Tue, 21 Jan 2014 10:27:37 -0800
Message-ID: <CALnjE+rkN5Nsoq0sOYaTH5gncPKUiK+ppBRc68ap7Vs-kYfqbw@mail.gmail.com>
References: <52DB8E4A.7050809@cn.fujitsu.com>
	<CALnjE+qtB4fEw4HdUZy6nXU6gSAjeSCiBn0EaQR9o_d2SY3yNQ@mail.gmail.com>
	<52DC7DE4.1050108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:50292 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754900AbaAUS1p convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 13:27:45 -0500
Received: by mail-vc0-f170.google.com with SMTP id hu8so3780236vcb.15
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 10:27:37 -0800 (PST)
In-Reply-To: <52DC7DE4.1050108@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 19, 2014 at 5:37 PM, Duan Jiong <duanj.fnst@cn.fujitsu.com>=
 wrote:
> =D3=DA 2014=C4=EA01=D4=C220=C8=D5 05:08, Pravin Shelar =D0=B4=B5=C0:
>> On Sun, Jan 19, 2014 at 12:35 AM, Duan Jiong <duanj.fnst@cn.fujitsu.=
com> wrote:
>>>
>>> When dealing with icmp messages, the skb->data points the
>>> ip header that triggered the sending of the icmp message.
>>>
>>> In gre_cisco_err(), the parse_gre_header() is called, and the
>>> iptunnel_pull_header() is called to pull the skb at the end of
>>> the parse_gre_header(). Unfortunately, the ipgre_err still needs
>>> the skb->data points the ip header following the icmp layer,
>>> and those ip addresses in ip header will be used to look up
>>> tunnel by ip_tunnel_lookup().
>>>
>> This looks like bug.
>> Can you use ip_hdr() rather than skb->data in ipgre_err().
>> Same is done in ipgre_rcv().
>
> That's maybe not a good idea. The ip_hdr() will the return the outmos=
t
> ip header, but we need inner ip header following the icmp layer.
>
Why do you want to use inner ip header?
If you want to really look at original packet header, you can
calculate it from outer iph header rather than changing fast path
parse_gre_header() function.
