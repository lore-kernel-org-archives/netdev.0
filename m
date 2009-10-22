From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rtnetlink: rtnl_setlink() and rtnl_getlink()
 changes
Date: Thu, 22 Oct 2009 06:48:38 +0200
Message-ID: <4ADFE426.6040806@gmail.com>
References: <4ADF7633.9050208@gmail.com> <20091022064839.6b343125@s6510> <4ADFCA82.80901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55867 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbZJVEsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 00:48:38 -0400
In-Reply-To: <4ADFCA82.80901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> On Wed, 21 Oct 2009 22:59:31 +0200
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>> Stephen, do you think we could change "ip link show dev ethX" to
>>> let it use rtnl_getlink() instead of rtnl_dump_ifinfo() ?
>>>
>> Would work, but not sure what it gains.
>=20
> It takes about one second to dump the table when we have 25.000 devic=
es

Adding new links takes also lot of time in rtnl_dump_ifinfo(), we could
optimize it using a 256 fanout (using the ifindex hash table instead
of the single list)

But IMHO rtnl_dump_ifinfo() should be used only when needed, not when
querying/adding a particular device.

-----------------------------------------------------------------------=
-------
   PerfTop:   42745 irqs/sec  kernel:88.0% [100000 cycles],  (all, 8 CP=
Us)
-----------------------------------------------------------------------=
-------

             samples    pcnt   kernel function
             _______   _____   _______________

           231146.00 - 52.4% : rtnl_dump_ifinfo
            18491.00 -  4.2% : __register_sysctl_paths
            17700.00 -  4.0% : mwait_idle
            12883.00 -  2.9% : rtnl_fill_ifinfo
            12661.00 -  2.9% : schedule
             6324.00 -  1.4% : find_busiest_group
             5911.00 -  1.3% : _spin_lock_irqsave
             4862.00 -  1.1% : dev_get_stats
             4726.00 -  1.1% : copy_to_user
             4547.00 -  1.0% : __nla_put
             4117.00 -  0.9% : sysfs_find_dirent
             4090.00 -  0.9% : sysenter_past_esp
             3789.00 -  0.9% : fput
             3735.00 -  0.8% : __nla_reserve
             3699.00 -  0.8% : read_tsc


