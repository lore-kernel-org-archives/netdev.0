From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Removing busy-spin in pktgen.
Date: Tue, 24 Oct 2006 15:09:13 -0700 (PDT)
Message-ID: <20061024.150913.10296964.davem@davemloft.net>
References: <17725.55765.509953.762136@robur.slu.se>
	<20061024.031455.55723788.davem@davemloft.net>
	<453E409E.9010002@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22212
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161227AbWJXWJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 18:09:09 -0400
To: greearb@candelatech.com
In-Reply-To: <453E409E.9010002@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 24 Oct 2006 09:34:38 -0700

> It could be a compile-time option, and even if compiled in, it should 
> only be an if  branch on
> a pointer.  Is there any noticeable performance hit for an if check if 
> you wrap it with unlikely?

It's "just an if test", yes, but it is such a test dependant
upon a memory access, and that pointer has to live somewhere
and that takes up space and conflicts with other members in
the cpu cache line.

Hooks of this nature are never free or cheap.
