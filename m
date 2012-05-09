From: Agarwal Nikhil-B38457 <B38457@freescale.com>
Subject: Memory exhaust issue with only IPsec policies configured on
 continuous traffic
Date: Wed, 9 May 2012 09:10:14 +0000
Message-ID: <F0B93D0554724543876B9A180DC988575B70E7@039-SN1MPN1-001.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"linux-netdev@vger.kernel.org" <linux-netdev@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:30183
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834Ab2EIJKc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 05:10:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 In a typical scenario, when =
IPSEC policies are configured in the system but SA is not present or ne=
gotiation fails or IKE daemon is not running. =A0The current behavior o=
f xfrm is to send those matching packets to blackhole route.=A0 i.e. xf=
rm_bundle_lookup returns a bundle with null route and xfrm_lookup retur=
ns a blackhole route.

=46or each of these packet a dst_alloc is called in ipv4_blackhole_rout=
e. However when these skbs get free and their dst's get discarded using=
 dst_free and the garbage collector is scheduled using cancel_delayed_w=
ork and schedule_delayed_work.

If the packets are coming continuously garbage collector may not get sc=
heduled and large amount of memory is stuck to be freed causing the sys=
tem to go into non-recoverable state.

Any ideas?=20

Regards
Nikhil
