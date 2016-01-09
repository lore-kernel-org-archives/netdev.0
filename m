From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Configure ICMP error source address
Date: Sat, 9 Jan 2016 10:57:31 +0100
Message-ID: <5690D98B.7070003@stressinduktion.org>
References: <568F8207.9040305@heinlein-support.de>
 <20160108152448.5251154.50977.21786@gmail.com>
 <568FDFBF.3010300@stressinduktion.org>
 <20160109035708.5251154.82433.21820@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: prmarino1@gmail.com, Robert Sander <r.sander@heinlein-support.de>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:42668 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753983AbcAIJ5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 04:57:34 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 6B33620853
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 04:57:33 -0500 (EST)
In-Reply-To: <20160109035708.5251154.82433.21820@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.01.2016 04:57, prmarino1@gmail.com wrote:
>   The reason why is in the kernel documentation distributed with the =
source code.
> =E2=80=8EIts not all immediately obvious why and where the kernel doe=
s this
unless you were involved in the original debates about it. The problems
with binding a public ip address to a loopback address are more
recently is partialy selinux but mostly of it is because of how routing
changed when iproute2 was introduced in the 2.2 kernel (if I remember
the versions correctly it was so long ago). The reason is security,
many processes bind to the loopback interface for IPC and just grab the
first address on the first lo device they find, some of the developers
of the applications weren't even aware they were doing it because in
some cases it was C libraries several layers deep doing it because odd
loopback addresses were common on UNIX ( I remember an AIX admin back
in the early 90's telling me I should always use addresses like
127.1.0.2 on the loopback because it was valid made it harder for
script kiddies to attack processes ). This was fine when additional
addresses would need additiona
l alias on the interface for ifconfig (lo:1 for example) but with iprou=
te2 you could now assign multiple ip addresses to an interface without =
creating an alias (commonly seen on the keepalived mailing list "why do=
esn't my VIP show up in ifconfig?")
> So there was a decision made to declare all subnets assigned to the l=
oopback interface as unroutable to prevent a lot of very common securit=
y holes that were being seen in the wild.

selinux can only affect what happens between user space and kernel=20
space, it cannot install policy what happens during forwarding if no=20
user space is involved.

In general the kernel makes sure nothing leaves or enters the system=20
with an address in the 127.0.0.0/8 subnet. Albeit we have a sysctl=20
nowadays to lift this restriction, sysctl_route_localnet.

Besides that I don't see any differences, as I bind addresses to the=20
loopback interface from time to time and it works.

One must just be careful if the kernel is switched from weak end mode=20
into a stong end mode by enabling more strict arp filters, but this=20
would also break setups with dummy interfaces.

> That said you can make it work but you have to do a lot of things you=
 should never do on a firewall like turn off selinux.=E2=80=8E Or you c=
an simply use the dummy driver and bind your public IP's to that and th=
e problems magically go away. And it makes a lot of sense why else woul=
d there be a need for the dummy network driver?

I would also use dummy interfaces in production systems, merely to spli=
t=20
the statistics from dummy.

Thanks,
Hannes
