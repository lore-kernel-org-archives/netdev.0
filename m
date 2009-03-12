From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Thu, 12 Mar 2009 17:34:54 +0100
Message-ID: <49B939AE.6010503@cosmosbay.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net> <49AE3DA9.2020103@cosmosbay.com> <49B2266C.9050701@cosmosbay.com> <49B3F655.6030308@cosmosbay.com> <49B59EA3.3000208@athenacr.com> <49B5FA84.9000301@cosmosbay.com> <49B6F645.2070408@athenacr.com> <49B72956.9050504@cosmosbay.com> <49B92E8C.6040908@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55212 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbZCLQfF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 12:35:05 -0400
In-Reply-To: <49B92E8C.6040908@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Bloniarz a =E9crit :
> Eric Dumazet wrote:
>> Here is an updated version of the patch.
>=20
> This works great in all my tests so far.
>=20
> Thanks,
> Brian Bloniarz

Cool

I am wondering if we should extend the mechanism and change
softirq_delay_exec() to wakeup a workqueue instead of
doing the loop from softirq handler, in case a given
level of stress / load is hit.

This could help machines with several cpus, and one NIC (without
multi RX queues) flooded by messages (not necessarly multicast trafic).
Imagine a media/chat server receiving XXX.000 frames / second

One cpu could be dedicated to pure softirq/network handling,
and other cpus could participate and handle the scheduler part if any.

Condition could be :=20

- We run __do_softirq() from ksoftirqd and=20
- We queued more than N 'struct softirq_delay' in softirq_delay_head
- We have more than one cpu online

