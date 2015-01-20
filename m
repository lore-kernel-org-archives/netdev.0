From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/2] udp: Do not require sock in udp_tunnel_xmit_skb
Date: Tue, 20 Jan 2015 23:47:29 +0200
Message-ID: <CAJ3xEMit2By8S=SwRGJKcwii9J3LKj29sX=tAbCC3bcAMDkr5Q@mail.gmail.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
	<1421518700-22460-2-git-send-email-therbert@google.com>
	<CAJ3xEMg0xJU4JShBLzs4g+zZVzH+uo79=aQGx4NwoQOv1h13Kw@mail.gmail.com>
	<CA+mtBx8dihFYb1v_WeyukfV5hk==2=3_b_GNUJoxCuL8_GUf6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:51265 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbbATVr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 16:47:29 -0500
Received: by mail-ob0-f173.google.com with SMTP id vb8so10417212obc.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 13:47:29 -0800 (PST)
In-Reply-To: <CA+mtBx8dihFYb1v_WeyukfV5hk==2=3_b_GNUJoxCuL8_GUf6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 7:36 PM, Tom Herbert <therbert@google.com> wrote:
> On Sun, Jan 18, 2015 at 2:43 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Sat, Jan 17, 2015 at 8:18 PM, Tom Herbert <therbert@google.com> wrote:
>>> The UDP tunnel transmit functions udp_tunnel_xmit_skb and
>>> udp_tunnel6_xmit_skb include a socket argument. The socket being
>>> passed to the functions (from VXLAN) is a UDP created for receive
>>> side. The only thing that the socket is used for in the transmit
>>> functions is to get the setting for checksum (enabled or zero).
>>
>> Tom, just to clarify - re the sockets usage in the transmit side,
>> somewhere bind or alike is done on them such that we have multiple
>> source UDP ports for given host VXLAN traffic. Here for example the
>> sender host is 192.168.31.17 and two ports are seen here 54206 and
>> 50795.
>>
>> Just wanted to make sure this series doesn't change that, since if
>> this is the case, we introduce here a regression w.r.t RSS hash
>> spreading from the outer UDP header data at the receiver side (which
>> is the right thing to do, per your LKS session...)
>>
> Hi Or,
>
> Using or not using a socket on transmit should have no bearing to the
> receive side. RSS works based on the hash of the UDP 5-tuple which
> should include a source port set to a value for the inner flow. Since
> the UDP socket is unconnected it should have no bearing on RFS or XPS
> either.

Hi Tom,

You say "which should include a source port set to a value for the
inner flow", well this series doesn't add such logic, nor I am fully
clear what piece exactly is responsible for the fact that I see
multiple source udp ports used from vxlan traffic flowing out of a
certain host. I just wanted to make sure that these patches don't
introduce a regression w.r.t to the **current** (not future) state of
things, can you confirm this?
