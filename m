From: David Miller <davem@davemloft.net>
Subject: Re: Excess use of packed attribute
Date: Mon, 07 Aug 2006 17:39:20 -0700 (PDT)
Message-ID: <20060807.173920.102575221.davem@davemloft.net>
References: <20060807133423.11bfbff3@localhost.localdomain>
	<1154995328.11916.24.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, rdreier@cisco.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16526
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932462AbWHHAjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 20:39:32 -0400
To: sri@us.ibm.com
In-Reply-To: <1154995328.11916.24.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 07 Aug 2006 17:02:08 -0700

> All the structures in sctp.h that use packed atrribute define
> standard on-wire SCTP chunk/parameter formats. They need to be at the
> exact offsets as they go on wire.
> I think we saw some issues without the packed attribute on 64-bit archs
> and just to be safe we added packed to all the on-wire structures.

For the cases where it is no actually necessary, the code generation
cost on RISC cpus is very high.  Byte loads and stores will be used to
access _every_ member of such structures on RISC machines because
the compiler cannot guarentee the alignment of any data object
when packed is specified.

It's OK to do this when it's really needed, but when it's not it
should be heavily avoided.
