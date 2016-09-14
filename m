From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 17:14:38 +0200
Message-ID: <87a8fapl7l.fsf@zoro.exoscale.ch>
References: <20160914124025.13417-1-vincent@bernat.im>
        <9540c014-78c5-9f9c-16d7-75a564f6c018@cumulusnetworks.com>
        <87h99ipnhu.fsf@zoro.exoscale.ch>
        <e8df55df-c22f-19a3-fabc-5fb592433706@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:57912 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761813AbcINPOo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 11:14:44 -0400
In-Reply-To: <e8df55df-c22f-19a3-fabc-5fb592433706@cumulusnetworks.com> (David
        Ahern's message of "Wed, 14 Sep 2016 08:39:15 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 14 septembre 2016 16:39 CEST, David Ahern <dsa@cumulusnetworks.c=
om>=C2=A0:

>>>> When a user wants to assign a routing table to a group of incoming
>>>> interfaces, the current solutions are:
>>>>
>>>>  - one IP rule for each interface (scalability problems)
>>>>  - use of fwmark and devgroup matcher (don't work with internal route
>>>>    lookups, used for example by RPF)
>>>>  - use of VRF devices (more complex)
>>>
>>> Why do you believe that? A VRF is a formalized grouping of interfaces
>>> that includes an API for locally generated traffic to specify which
>>> VRF/group to use. And, with the l3mdev rule you only need 1 rule for
>>> all VRFs regardless of the number which is the best solution to the
>>> scalability problem of adding rules per device/group/VRF.
>>>
>>> What use case are trying to solve?
>>=20
>> Local processes have to be made aware of the VRF by binding to the
>> pseudo-device. Some processes may be tricked by LD_PRELOAD but some
>> won't (like stuff written in Go). Maybe I should just find a better way
>> to bind a process to a VRF without its cooperation.
>
> What API are you using for interface groups? How does an app tell the
> kernel to use interface group 1 versus group 2?

In my testbed, I have only one local application which is dnsmasq as a
DHCP server. It sends back the answer to the physical interface (with
sendmsg() and auxillary data). So it makes my argument a bit moot as the
situation is in fact worse without VRF. :-/

My testbed is here (with use of VRF, more recent commits just use plain
ip rules):

 https://github.com/vincentbernat/network-lab/blob/d86e9ed658863ef0f51d7b85=
3d0dc9f8b7427b21/lab-l3-hyperv/setup

I could just give more time to VRF. I also had some concerns over
performance with the way Netfilter integration is done, but I understand
that I could just stay away from POSTROUTING rules which is the only
hook executed twice?
--=20
All things that are, are with more spirit chased than enjoyed.
		-- Shakespeare, "Merchant of Venice"
