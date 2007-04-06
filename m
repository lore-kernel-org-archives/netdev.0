From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: L2 network namespace benchmarking (resend with Service Demand)
Date: Fri, 06 Apr 2007 02:03:47 -0600
Message-ID: <m1d52i9bfg.fsf@ebiederm.dsl.xmission.com>
References: <460D1BBC.9090602@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36970 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932501AbXDFIE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 04:04:27 -0400
In-Reply-To: <460D1BBC.9090602@fr.ibm.com> (Daniel Lezcano's message of "Fri,
	30 Mar 2007 16:16:28 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> Hi,
>
> as suggested Rick, I added the Service Demand results to the matrix.

A couple of random thoughts in trying to understand the numbers you are
seeing.

- Checksum offloading?

  You have noted that with the bridge netfilter support disabled you
  are still seeing additional checksum overhead.  Just like you are
  seeing in the routing case.

  Is it possible the problem is simply that etun doesn't support
  checksum offloading, while your normal test hardware does?

- Tagged VLANs?
  
  Currently you have tested bridging and routing to get the packets to
  a network namespace.  Could you test tagged vlans?

  I'm just curious if we have anything in the network stack today that
  will multiplex a NIC without measurable overhead.

- Without NETNS?

  We should probably see if we can setup the same configuration we are
  testing without network namespaces (just multiple interfaces on the
  same machine) and see if we can still measure the same overhead.
  Just to confirm the overhead is not a network namespace related
  thing.

  I know we can configure the same case with bridging and I am fairly
  confident that we will see the same overhead without network
  namespaces.

  Of the top of my head I am insufficiently clever to think how we
  could configure the routing case without network namespaces,
  although we might be able to force it and if so it would be
  interesting to measure.

I will work to get the etun setup races fixed and to fix whatever
obvious feature deficiencies it has (like no configurable MTU support)
and see if I can get that pushed upstream.  That should make it easier
for other people to reproduce what we are seeing.

Eric
