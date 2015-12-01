From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: memory leak in do_ipv6_setsockopt
Date: Tue, 01 Dec 2015 06:38:43 -0800
Message-ID: <1448980723.25582.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+bv56b+opCd=5SHmN47MAHEFyZA18kSsu-Fa+XODj20PA@mail.gmail.com>
	 <1448977016.25582.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DA9BE.3060006@iogearbox.net>
	 <1448979404.25582.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DAD8D.9020800@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34412 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216AbbLAOiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 09:38:46 -0500
In-Reply-To: <565DAD8D.9020800@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 15:24 +0100, Daniel Borkmann wrote:
> On 12/01/2015 03:16 PM, Eric Dumazet wrote:
> > On Tue, 2015-12-01 at 15:07 +0100, Daniel Borkmann wrote:
> >
> >> Yeah, we miss inet6_destroy_sock() in SCTP. :-(
> >>
> >> Looks good to me.
> >
> > OK, I will send a formal (and tested ;) ) patch.
> 
> I was shortly wondering whether there could be a use-after-free by
> doing this after sctp_destroy_sock() due to the sctp_endpoint_destroy()
> that would eventually drop a ref on the socket, but the endpoint holds
> a separate ref, so we should be good.
> 

More generically ->destroy() caller must keep a reference on the socket.

inet_csk_destroy_sock() for example uses sk after

sk->sk_prot->destroy(sk);
