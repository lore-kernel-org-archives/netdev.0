From: "Light, John J" <john.j.light@intel.com>
Subject: RE: possible bug in latest network tree
Date: Wed, 30 Mar 2016 21:05:30 +0000
Message-ID: <660C7E53FDDFB64C8741117E0D659AAAB8463B9F@ORSMSX116.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:31271 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156AbcC3VHI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 17:07:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

I see a recent change in inet_connection_sock.c that uses sysctl_tcp_sy=
nack_retries suspiciously.

Previously, sysctl_tcp_synack_retries was a global variable, and now it=
 has been moved into the fragment (really netns_ipv4).

In reqsk_timer_handler (inet_connection_sock.c) near line 563 it is use=
d as the default max_retries value in case icsk->icsk_syn_retries is no=
t set.

Previously, other transports (dccp?) would use the TCP global variable =
as a default.=A0 Now that the defaults come from the fragment, I suspec=
t the fragment variable is not set for other transports.=A0 (I can't fi=
nd where it's set for dccp.)

Of course, this will only show in non-TCP transport protocols when the =
icsk retries value is not set, so it's a rare case.=A0 Perhaps it's an =
unreachable case, since I don't know all the kernel paths.

Maybe the problem is that the default shouldn't be to a TCP value, but =
should be a 'transport' value.

This code is somewhat convoluted, so I am not sure of my analysis, but =
I wanted you to consider it.

John Light
Intel OTC comms
