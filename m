From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 14:33:57 +0200
Message-ID: <87d2tlv32i.fsf@nemi.mork.no>
References: <1366701302.21136.19.camel@cr0>
	<20130423.031805.544535198246859192.davem@davemloft.net>
	<1366702220.21136.23.camel@cr0>
	<20130423.033620.1101068519499870853.davem@davemloft.net>
	<1366702893.21136.28.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59468 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755000Ab3DWMeP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 08:34:15 -0400
In-Reply-To: <1366702893.21136.28.camel@cr0> (Cong Wang's message of "Tue, 23
	Apr 2013 15:41:33 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> On Tue, 2013-04-23 at 03:36 -0400, David Miller wrote:
>> From: Cong Wang <amwang@redhat.com>
>> Date: Tue, 23 Apr 2013 15:30:20 +0800
>>=20
>> > This is hard to do, as in the email I replied to Stephen. So I
>> > prefer to just add a Kconfig dependency, at least for now.
>>=20
>> A Kconfig hack is exactly what I've told you is an unacceptable
>> solution.
>
> Please enlighten me for a third solution. :)

This is an completely untested idea....

I note that vxlan_init_net requires a successful sock_create_kern().
That implies a request_module("net-pf-...") followed by try_module_get.

So if the sock_create_kern(PF_INET6, ..) succeeds then you *know* you
have IPv6. If it fails with -EAFNOSUPPORT, then you could fall back to
sock_create_kern(PF_INET, ..) and set a flag indicating that runtime
IPv6 support is disabled.  Then use this flag to allow/deny configuring
any IPv6 destinations.

You may also have to protect the IPv6 modular symbols you use with
symbol_request() or similar to prevent vxlan from depending on IPv6.  I
dunno...

If nothing else, I believe this is a crazy enough hack that David may
want to reconsider one of your other two solutions :)



Bj=C3=B8rn
