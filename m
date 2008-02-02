From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: why does DCCP SO_REUSEADDR have to be SOL_DCCP?
Date: Sat, 2 Feb 2008 01:02:51 -0200
Message-ID: <20080202030251.GJ17164@ghostprotocols.net>
References: <47A3CA7F.8040300@hp.com> <20080202025259.GH17164@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707AbYBBDDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 22:03:00 -0500
Content-Disposition: inline
In-Reply-To: <20080202025259.GH17164@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Feb 02, 2008 at 12:52:59AM -0200, Arnaldo Carvalho de Melo escreveu:
> If instead you pass SOL_DCCP we'll go down the rabbit hole till
> do_dccp_setsockopt() and SO_REUSEADDR, that is equal to 2, will be
> interpreted as DCCP_SOCKOPT_SERVICE, that is also equal to 2, so you'll
> be setting the service, not changing the SO_REUSEADDR setting.
> 
> The problem here is that you need to use:
> 
> setsockopt(fd, SOL_DCCP, DCCP_SOCKOPT_PACKET_SIZE, service,
>            sizeof(service));

Further info on DCCP service codes:

http://www.rfc.net/rfc4340.txt -> "8.1.2.  Service Codes"
 
> Again, take a look at the ttcp patch, the other patches for iperf,
> netcat, etc handles this.

- Arnaldo
