From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Tue, 13 Mar 2012 09:52:07 -0400
Message-ID: <1331646727.3147.11.camel@mojatatu>
References: <1329315057.4158.15.camel@mojatatu> <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu> <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com>
	 <20120305165339.GS12271@wantstofly.org>
	 <1331041346.2374.108.camel@mojatatu>
	 <20120306140957.GA27559@wantstofly.org> <1331129500.2237.72.camel@mojatatu>
	 <20120312084850.GB28523@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:54513 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754344Ab2CMNwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 09:52:14 -0400
Received: by vcqp1 with SMTP id p1so620818vcq.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 06:52:14 -0700 (PDT)
In-Reply-To: <20120312084850.GB28523@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-12 at 09:48 +0100, Lennert Buytenhek wrote:

> Since it can lead to problems (address database mismatches, doesn't
> correctly handle STP transitions or topology changes automatically),
> I think it should be avoided whenever possible.  I don't see any
> advantages of hardware based learning over software based learning
> anyway ('flexibility' doesn't seem like a very good argument).

Indeed address mismatches may happen if you have two databases. 
You have two choices then:
Do learning in user space or be able to tolerate some transient 
inconsistency (if you have some software that lazily looks at the
database). But there is a case where the database sits only in hardware.
In such a case, you cant have mismatches.
I think the STP problem can be handled by user space regardless of
whether address mismatch happens or not.

> It should be doable along the lines of the current DSA patch --
> add a VLAN ID argument to the interface add/remove callbacks, and
> when a VLAN virtual interface is added to the bridge, call the
> relevant callbacks with the parent interface + VLAN ID instead.
> (This doesn't work for stacked VLANs, but the current net/dsa
> supported chips don't handle those anyway.)

Sounds like a good start - we could have a different interface for
stacked variants. I think you should push in the patch.

cheers,
jamal
