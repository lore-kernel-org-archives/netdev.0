From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Mon, 16 Apr 2007 10:22:46 +1000
Message-ID: <1176682966.14322.193.camel@localhost.localdomain>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>
	 <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
	 <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
	 <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
	 <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
	 <20070404212103.GA19026@elte.hu>
	 <1175728768.12230.593.camel@localhost.localdomain>
	 <4614A294.3000607@qumranet.com>
	 <1175821357.12230.642.camel@localhost.localdomain>
	 <46187F4E.1080807@qumranet.com>
	 <1176087018.11664.65.camel@localhost.localdomain>
	 <4619E6DC.3010804@qumranet.com>
	 <1176111984.11664.90.camel@localhost.localdomain>
	 <461A41CA.9080201@qumranet.com>
	 <1176263593.26372.84.camel@localhost.localdomain>
	 <461C6360.1060908@qumranet.com>
	 <1176297794.14322.72.camel@localhost.localdomain>
	 <461CF098.3090003@qumranet.com>
	 <1176334200.14322.133.camel@localhost.localdomain>
	 <461DA849.50406@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37542 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123AbXDPAXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Apr 2007 20:23:22 -0400
In-Reply-To: <461DA849.50406@qumranet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-04-12 at 06:32 +0300, Avi Kivity wrote:
> I hadn't considered an always-blocking (or unbuffered) networking API. 
> It's very counter to current APIs, but does make sense with things like
> syslets.  Without syslets, I don't think it's very useful as you need
> some artificial threads to keep things humming along.
> 
> (How would userspace specify it? O_DIRECT when opening the tap?)

TBH, I hadn't thought that far.  Tap already has those IFF_NO_PI etc
flags, but it might make sense to just be the default.  From userspace's
POV it's not a semantic change.

OK, just tested: I can get 230,000 packets (28 byte UDP) through the tun
device in a second (130,000 actually out the 100-base-T NIC, 100,000
dropped).  If the tun driver's write() blocks until the skb is
destroyed, it's 4,000 packets.

So your intuition was right: skb_free latency on xmit (at least for this
e1000) is far too large for anything but an async solution.

Will ponder further.

Thanks!
Rusty.


