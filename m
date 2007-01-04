From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 3 Jan 2007 21:34:06 -0800
Message-ID: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com>
References: <E1H2GVF-0008GJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: greearb@candelatech.com, jarkao2@o2.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33590 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932277AbXADFeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 00:34:13 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l045YAu8004196
	for <netdev@vger.kernel.org>; Thu, 4 Jan 2007 00:34:10 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l045YALL387452
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 22:34:10 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l045Y9Ag016149
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 22:34:09 -0700
In-Reply-To: <E1H2GVF-0008GJ-00@gondolin.me.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,
        You're right, I don't know whether it'll fix the problem Ben saw
or not, but it looks like the original code can do a receive before the
in_device is fully initialized, and that, of course, is bad.
        If the device for ip_rcv() is not the same one we were
initializing when the receive interrupted, then the patch should have
no effect either way -- I don't think it'll hide other problems.
        If it's hard to reproduce (which I guess is true), then you're
right, no soft lockup doesn't really tell us if it's fixed or not.

                                        +-DLS

