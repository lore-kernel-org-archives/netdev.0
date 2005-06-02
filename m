From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 02 Jun 2005 15:12:12 -0700 (PDT)
Message-ID: <20050602.151212.35014607.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408>
	<20050602143126.7c302cfd@dxpl.pdx.osdl.net>
	<200506021651.49013.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, john.ronciak@intel.com, hadi@cyberus.ca,
        mitch.a.williams@intel.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <200506021651.49013.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Thu, 2 Jun 2005 16:51:48 -0500

> Why not have the driver set the weight to 16/32 respectively for the
> weight (or better yet, have someone run numbers to find weight that
> are closer to what the adapter can actually use)?  While these
> numbers may not be optimal for every system, this is much better
> that the current system, and would only require 5 or so extra lines
> of code per NAPI enabled driver.

Why do this when we can adjust the weight in one spot,
namely the upper level NAPI ->poll() running loop?

It can measure the overhead, how many packets processed, etc.
and make intelligent decisions based upon that.  This is a CPU
speed, memory speed, I/O bus speed, and link speed agnostic
solution.

The driver need not take any part in this, and the scheme will
dynamically adjust to resource usage changes in the system.
