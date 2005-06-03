From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 11:49:50 -0700 (PDT)
Message-ID: <20050603.114950.119242486.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>
	<42A0A25C.8000503@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, Robert.Olsson@data.slu.se, jdmason@us.ibm.com,
        shemminger@osdl.org, hadi@cyberus.ca, mitch.a.williams@intel.com,
        netdev@oss.sgi.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <42A0A25C.8000503@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 03 Jun 2005 11:33:00 -0700

> Is this implying that having the NAPI poll do less work per poll
> of the driver actually increases performance?  I would have guessed that
> the opposite would be true.

Exactly my thoughts as well :)

> Maybe the poll is disabling the IRQs on the NIC for too long, or something
> like that?

In a reply I just sent out to this thread, I postulate that the
jiffies check is hitting earlier with a lower weight value, a quick
look at /proc/net/softnet_stat during their testing will confirm or
deny this theory.

It could also just be a simple bug in the dev->quota accounting
somewhere.

Note that, in all of this, I do not have any objections to providing
a way to configure the dev->weight values.  I will be applying Stephen
Hemminger's patches.

But I think we MUST find out the reason for the observed behavior,
especially in the single-adapter case since the result is so illogical.
We could find an important bug in the NAPI implementation, or learn
something new about how NAPI behaves.
