From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: NDA_PORT attribute is useless
Date: Sat, 18 May 2013 00:08:53 -0400
Message-ID: <OF7329FB93.18E31915-ON85257B6F.00161446-85257B6F.0016C9AC@us.ibm.com>
References: <20130517205457.61dbaae2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:48137 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab3EREI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 00:08:59 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 17 May 2013 22:08:58 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 659141FF001D
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 22:03:49 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4I48uYY089580
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 22:08:56 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4I48uW2020410
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 22:08:56 -0600
In-Reply-To: <20130517205457.61dbaae2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 05/17/2013 
11:54:57 PM:

> I noticed that this commit is also broken.
> Because although you can specify alternate UDP ports for sending,
> it does nothing to enable those ports for reception. So although you
> can create new static neighbour entries with different ports, they
> are useless.

On Host A:
modprobe vxlan

on Host B:
modprobe vxlan udp_port=9462

...and whatever you want on any other hosts.

Then you want to connect a segment on Host A and
Host B. The fdb entries on Host A that point to
Host B should use "port 9462"; the fdb entries on
Host B that have destination Host A should use
"port 8472".

And if Host C is an external switch using 4789, its
fdb entries should use "port 4789".

It does exactly what it is supposed to do, allow these
hosts to use VXLAN with each other, and has nothing to do
with listening on multiple ports.

                                                        +-DLS
