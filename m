From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: bonding directly changes underlying device address
Date: Wed, 14 May 2014 11:08:41 +0300
Message-ID: <53732489.3070204@mellanox.com>
References: <5371FCD0.7050502@mellanox.com> <20140513115527.GC2910@minipsycho.orion> <20030.1399998641@localhost.localdomain> <CAJZOPZ+pOBw4M-ZFF2qsqNgGJcKcRRdhWFf4dy1FQ8Ngr-ZqRA@mail.gmail.com> <20140514080114.GA30960@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	"Eyal Perry" <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:49142 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752815AbaENILx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 04:11:53 -0400
In-Reply-To: <20140514080114.GA30960@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/2014 11:01, Veaceslav Falico wrote:
>
> I'd actually just drop support for non-ndo_set_mac_address NICs, as it'll
> unify the RLB and TLB logic, and anyways dev_set_mac_address() is used in
> SIOCSIFHWADDR and rtnl ops, and thus, if the NIC doesn't support it, it
> can't change its mac address at all, and using it in *LB modes makes 
> little sense.

Avoid touching the slave device address directly and acting through 
dev_set_mac_address() sounds good to me.

Still, FWIW && just to make sure we see the whole picture, we noted that 
the practiceof manually touching the slave device address is done in 
another TLB code locationbesides alb_set_slave_mac_addr(), namely in 
alb_set_mac_address().

>
> Other way of doing this would be to just move the dev_addr to the slave
> struct, instead of using the net_device's dev_addr, cause in tlb we don't
> usually need to set the NIC mac address (except when there's mac 
> filtering,
> I guess), but only need to set the packet's source mac. This way we'll 
> omit
> quite costy mac address setting (as, on some NICs, it resets the whole 
> NIC
> and takes seconds), still maintain compatibility with older NICs and 
> won't
> mess with NICs ->dev_addr.

Interesting, so if Jay is OK with this design, any chance one of you can 
come up
with the proper patch to make that happen?

Or.
