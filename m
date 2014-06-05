From: Cong Wang <cwang@twopensource.com>
Subject: Re: Bug 75571
Date: Thu, 5 Jun 2014 12:18:06 -0700
Message-ID: <CAHA+R7Mi-mBXWSytEtJhqEfjYQyrd9zae5GndYy3qmK=+_mk_g@mail.gmail.com>
References: <1401085231.1775.9.camel@anpws>
	<CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
	<1401870692.29664.1.camel@anpws>
	<CAHA+R7N74QODqvWyvP1gHsK2dm_Zgrkq0+k8LZnqnA8EqnMOZw@mail.gmail.com>
	<1401945732.29664.6.camel@anpws>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Alex <d77190@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:53596 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbaFETSH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 15:18:07 -0400
Received: by mail-qg0-f49.google.com with SMTP id a108so2324915qge.8
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 12:18:06 -0700 (PDT)
In-Reply-To: <1401945732.29664.6.camel@anpws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 4, 2014 at 10:22 PM, Alex <d77190@mail.ru> wrote:
> =D0=92 =D0=A1=D1=80, 04/06/2014 =D0=B2 17:27 -0700, Cong Wang =D0=BF=D0=
=B8=D1=88=D0=B5=D1=82:
>
>> Thanks for testing!
>>
>> Thinking a bit more, the question is why
>> skb_push(skb->dev->hard_header_len) is not correct here? It looks
>> like we don't calculate tunnel->dev->hard_header_len correctly. But
>> ipip_tunnel_bind_dev() should do the right thing less your setup is =
not
>> correct, in that case your ipip tunnel should not receive any packet=
=2E
>> We should be safe.
>>
>> Which is the interface routing to 192.168.18.17 on your system? Whic=
h
>> driver does it use?
>
> Its a stock e1000e from kernel with no special options. No jumbo fram=
es,
> etc.
>
> lspci says:
> Ethernet controller: Intel Corporation 82572EI Gigabit Ethernet
> Controller (Copper) (rev 06)
>
> IPIP tunnel runs on top of this interface.
>

Hmm, e1000e should init dev->hard_header_len to ETH_LEN, which is 14.
Plus IPv4 header len (20), it should be about 34. I don't understand wh=
y
the ipip tunnel's hard_header_len is 148 in your case. It is only possi=
ble when
there is no underlying interface, that is, LL_MAX_HEADER + sizeof(struc=
t iphdr).

What do `ip -d link show` and `ip route show` say?
