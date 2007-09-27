From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: Dynamically allocate the per cpu counters for
 the loopback device.
Date: Thu, 27 Sep 2007 13:56:16 -0700 (PDT)
Message-ID: <20070927.135616.37572002.davem@davemloft.net>
References: <m1myv8r1lb.fsf@ebiederm.dsl.xmission.com>
	<20070927.115200.56183114.davem@davemloft.net>
	<m1ps03hm8a.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755276AbXI0U4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 16:56:16 -0400
In-Reply-To: <m1ps03hm8a.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Sep 2007 14:44:37 -0600

> David Miller <davem@davemloft.net> writes:
> 
> > From: ebiederm@xmission.com (Eric W. Biederman)
> > Date: Thu, 27 Sep 2007 01:48:00 -0600
> >
> >> I'm not doing get_cpu/put_cpu so does the comment make sense
> >> in relationship to per_cpu_ptr?
> >
> > It is possible.  But someone would need to go check for
> > sure.
> 
> Verified.
> 
> hard_start_xmit is called inside of a
> rcu_read_lock_bh(),rcu_read_unlock_bh() pair.  Which means
> the code will only run on one cpu.
> 
> Therefore we do not need get_cpu/put_cpu.
> 
> In addition per_cpu_ptr is valid.  As it is just a lookup
> into a NR_CPUS sized array by smp_processor_id() to return
> the address of the specific cpu.
> 
> The only difference between per_cpu_ptr and __get_cpu_var()
> are the implementation details between statically allocated
> and dynamically allocated per cpu state.
> 
> So the comment is still valid, and still interesting it just
> should say per_cpu_ptr instead of __get_cpu_var.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

I've already removed the comment, so you'll have to give
me a patch that adds it back with the new content :-)
