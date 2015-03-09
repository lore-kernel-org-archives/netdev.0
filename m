From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/6] tcp_metrics: Network namespace bloat reduction
Date: Mon, 09 Mar 2015 13:22:52 -0500
Message-ID: <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35628 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbCIS0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:26:33 -0400
In-Reply-To: <20150219.144929.1003473344851168804.davem@davemloft.net> (David
	Miller's message of "Thu, 19 Feb 2015 14:49:29 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a small pile of patches that convert tcp_metrics from using a
hash table per network namespace to using a single hash table for all
network namespaces.

This is broken up into several patches so that each small step along
the way could be carefully scrutinized as I wrote it, and equally so
that each small step can be reviewed.

There are two minor cleanups included.  The addition of a missing panic
when the tcp_metrics hash table can not be allocated during boot and the
removal of the return code from tcp_metrics_flush_all

The motivation for this change is that the tcp_metrics hash table at
128KiB is the single largest component of a freshly allocated network
namespace.

Eric W. Biederman (6):
      tcp_metrics: panic when tcp_metrics can not be allocated
      tcp_metrics: Mix the network namespace into the hash function.
      tcp_metrics: Add a field tcpm_net and verify it matches on lookup
      tcp_metrics: Remove the unused return code from tcp_metrics_flush_all
      tcp_metrics: Rewrite tcp_metrics_flush_all
      tcp_metrics: Use a single hash table for all network namespaces.

 include/net/netns/ipv4.h |   2 -
 net/ipv4/tcp_metrics.c   | 118 +++++++++++++++++++++++++++++------------------
 2 files changed, 73 insertions(+), 47 deletions(-)
