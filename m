From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Tue, 26 Apr 2005 19:09:01 -0700
Message-ID: <200504270209.j3R291ml007431@death.nxdomain.ibm.com>
References: <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: Message from Herbert Xu <herbert@gondor.apana.org.au>
   of "Tue, 26 Apr 2005 21:18:45 +1000." <20050426111845.GA8968@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
[...]
>Indeed.  But how can this stuff work at all? Surely if use_carrier is
>disabled while miimon is enabled we should get a dead-lock as soon as
>this call chain is run:
>
>dev_ioctl => bond_enslave => bond_check_dev_link => slave_dev->ioctl

	Why would it deadlock?  dev_ioctl holds RTNL, bonding grabs
various bond locks, and the slave device ioctl handler may or may not
get a lock of its own.  

>> 	It is better, performance-wise, to run the "main" part of the
>> link monitoring in a timer, and then call out to a work queue only for
>> those operations that need a context?  I.e., how expensive are work
>> queues compared to timers?
>
>For the amount of work that these timers are doing, the overhead is
>pretty small.  It is also gentler on the system when the CPU load
>goes up.

	Just so I'm clear: by "the overhead" do you mean the overhead of
running everything in a work queue, or the overhead of calling out from
a timer to a work queue for "special occasions"?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
