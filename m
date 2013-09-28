From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] net ipv4: Convert ipv4.ip_local_port_range to be per netns
Date: Sat, 28 Sep 2013 13:32:38 -0700
Message-ID: <87bo3cn0ux.fsf@xmission.com>
References: <87fvswt5m5.fsf@tw-ebiederman.twitter.com>
	<20130928.155228.211244914284752204.davem@davemloft.net>
	<20130928.160753.1218915059639502436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39463 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991Ab3I1Ucq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 16:32:46 -0400
In-Reply-To: <20130928.160753.1218915059639502436.davem@davemloft.net> (David
	Miller's message of "Sat, 28 Sep 2013 16:07:53 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: David Miller <davem@davemloft.net>
> Date: Sat, 28 Sep 2013 15:52:28 -0400 (EDT)
>
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Sun, 22 Sep 2013 23:27:30 -0700
>>=20
>>>=20
>>> - Move sysctl_local_ports from a global variable into struct netns_=
ipv4.
>>> - Modify inet_get_local_port_range to take a struct net.
>>> - Manually expand inet_get_local_range into ipv4_local_port_range
>>>   because I do not know the struct net.
>>> - Move the initialization of sysctl_local_ports into
>>>   sysctl_net_ipv4.c:ipv4_sysctl_init_net from inet_connection_sock.=
c
>>>=20
>>> Originally-by: Samya <samya@twitter.com>
>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>=20
>> Applied.
>
> I had to revert, you didn't throughly build test this.

My apologies, I was pushing a little too hard that day.  v3 will be
coming with the fix.

> security/selinux/hooks.c: In function =E2=80=98selinux_socket_bind=E2=
=80=99:
> security/selinux/hooks.c:3933:4: error: incompatible type for argumen=
t 1 of =E2=80=98inet_get_local_port_range=E2=80=99
> In file included from security/selinux/hooks.c:53:0:
> include/net/ip.h:206:6: note: expected =E2=80=98struct net *=E2=80=99=
 but argument is of type =E2=80=98struct lsm_network_audit=E2=80=99
>
> And when you repost make sure to deal with the space vs. TAB
> issues pointed out to you.

Definitely.

Eric
