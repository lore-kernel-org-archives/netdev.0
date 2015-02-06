From: =?UTF-8?B?RXJlbiBUw7xya2F5?= <erent@skyatlas.com>
Subject: Re: PROBLEM: Bnx2x Checksum/Length Error Over GRE Tunnel
Date: Fri, 06 Feb 2015 09:51:17 +0200
Message-ID: <54D47275.6070707@skyatlas.com>
References: <54D0A345.2030108@skyatlas.com> <54D10DFE.1070604@skyatlas.com> <1422989196.907.34.camel@edumazet-glaptop2.roam.corp.google.com> <54D1EDCE.3030602@skyatlas.com> <B5657A6538887040AD3A81F1008BEC63BE78AC@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfw.csoftintl.com ([209.11.253.18]:37374 "EHLO
	fmvm01.lax10.vpls.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754457AbbBFHv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 02:51:26 -0500
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63BE78AC@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-02-2015 18:13, Yuval Mintz wrote:
> Tried this on latest net-next [using iproute2] and I didn't manage to hit the
> issue you've indicated.
> I.e., traffic seemed to work fine on gre tunnels using both mtu sizes and
> regardless of whether Tx-checksum-offload was enabled or disabled.

Interesting. Could it be a firmware issue?

To summarize my current situation, I cannot get the network work with tx on so I
need to disable tx. Using iproute2, tunnels with MTU 8976 works OK (getting
9.7Gbit/s in a single flow). When MTU is decreased to 1500, I can only get
3-4Gbit/s.

Being unable to use tx offloading is strange.

> Is there anything else which is worth mentioning in your setup?

For iproute2, I don't have anything special. I just create a tunnel bridge and
test it. For OVS part, I have openstack installation using neutron openvswitch
plugin, which is irrelevant for now. Openvswitch kernel module is loaded but
does it have an effect on iproute2? Please inform me if you need anything else.

Just to inform other people having the same issue, by increasing the MTU of OVS
bridges (br-int, tap, qvo, qbr, etc.) to 8950, setting br-tun ovs bridge to
8976, and instructing VMs to use 8950 MTU, I can now get 7.5Gbit from
VM-to-network node using GRE tunnel in a single flow, and 9.5Gbit using 2 flows.
I should add that I needed to enable MQ in libvirt.xml (using 4 queues).

> Thanks,
> Yuval

Regards,
Eren

-- 
System Administrator
https://skyatlas.com/
