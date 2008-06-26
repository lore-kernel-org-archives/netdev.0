From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: TCP MD5 and socket accept
Date: Thu, 26 Jun 2008 13:37:08 -0700
Message-ID: <396556a20806261337n794c22nf538a0953c942879@mail.gmail.com>
References: <20080625225657.61e1b29b@extreme>
	 <396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"=?UTF-8?B?5ZCJ6Jek6Iux5piO?=" <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:5927 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755423AbYFZUhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 16:37:08 -0400
Received: by rv-out-0506.google.com with SMTP id k40so201181rvb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 13:37:08 -0700 (PDT)
In-Reply-To: <396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2008 at 7:46 AM, Adam Langley <agl@imperialviolet.org> wrote:
> I'll have a look at this later today

Setup: Linux net-2.6 (almost) <-> Linux net-2.6 (almost)). Userspace
is only setting TCP_MD5SIG just before connect on the client side and
just before bind on the server side. Packet dumps show that all
packets are signed correctly.

>From the code, it appears that we might, in fact, be coping the key
information twice:

tcp_minisocks.c:tcp_check_req is calling
inet_csk(sk)->icsk_af_ops->syn_recv_sock, which becomes
tcp_ipv4.c:tcp_v4_syn_recv_sock which appears to copy the MD5 keys
over. Additionally, right after that call in tcp_check_req, it appears
that the keys are copied again.

Can you provide packet dumps of Linux screwing up in the face of a
connection to a Cisco?

Cheers,

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
