From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH v2] netfilter: fix bad checksum on IPv6 when NAT is
 performed
Date: Thu, 08 Oct 2015 23:26:34 +0200
Message-ID: <1444339594.14655.392.camel@sakura.staff.proxad.net>
References: <1444141425.14655.341.camel@sakura.staff.proxad.net>
	 <1444335587.14655.387.camel@sakura.staff.proxad.net>
	 <1444335972.14655.388.camel@sakura.staff.proxad.net>
	 <CALx6S37AdH=icFEqXjH5hDJ2O0dkwLEx6_KqpFkoPYF2sr1N_Q@mail.gmail.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	kaber <kaber@trash.net>, pablo@netfilter.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:45294 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754172AbbJHV0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 17:26:36 -0400
In-Reply-To: <CALx6S37AdH=icFEqXjH5hDJ2O0dkwLEx6_KqpFkoPYF2sr1N_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2015-10-08 at 14:09 -0700, Tom Herbert wrote:

> I think inet_proto_csum_replace16 should be called here.

inet_proto_csum_replace16() wants a non NULL checksum pointer to update,
and there is no such thing here.

I could pass a dummy value, but inet_proto_csum_replace16() will do
twice more work for nothing

or I could modify inet_proto_csum_replace16() to allow a NULL sum
argument.

-- 
Maxime
