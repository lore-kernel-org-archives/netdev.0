From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/8] Add complementary BPF conditional jump
 instructions
Date: Mon, 31 Dec 2012 19:29:02 -0800
Message-ID: <1357010942.21409.8948.camel@edumazet-glaptop>
References: <cover.1356960070.git.dborkman@redhat.com>
	 <20121231.143715.1238174487756359071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:59849 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab3AAD3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 22:29:05 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb11so7352868pad.38
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2012 19:29:04 -0800 (PST)
In-Reply-To: <20121231.143715.1238174487756359071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-31 at 14:37 -0800, David Miller wrote:

> Whilst I agree that adding NE jumps adds great value and closes a
> serious gap, the rest can be synthesized by simply swapping the
> arguments and using a comparison that does already exist.
> 
> Why isn't that sufficient?

I am afraid none of these patches is needed at all.

Swapping the jt/jf is plainly enough for the user land compiler.

libcap seems to do it already

# tcpdump -i lo 'len!=0 && ip6' -d
(000) ld       #pktlen
(001) jeq      #0x0             jt 5	jf 2
(002) ldh      [12]
(003) jeq      #0x86dd          jt 4	jf 5
(004) ret      #96
(005) ret      #0
# tcpdump -i lo 'len==0 && ip6' -d
(000) ld       #pktlen
(001) jeq      #0x0             jt 2	jf 5
(002) ldh      [12]
(003) jeq      #0x86dd          jt 4	jf 5
(004) ret      #96
(005) ret      #0
