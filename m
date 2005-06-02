From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 2 Jun 2005 17:19:46 -0500
Message-ID: <200506021719.47459.jdmason@us.ibm.com>
References: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408> <200506021651.49013.jdmason@us.ibm.com> <20050602.151212.35014607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, john.ronciak@intel.com, hadi@cyberus.ca,
        mitch.a.williams@intel.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050602.151212.35014607.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 02 June 2005 05:12 pm, David S. Miller wrote:
> From: Jon Mason <jdmason@us.ibm.com>
> Date: Thu, 2 Jun 2005 16:51:48 -0500
>
> > Why not have the driver set the weight to 16/32 respectively for the
> > weight (or better yet, have someone run numbers to find weight that
> > are closer to what the adapter can actually use)?  While these
> > numbers may not be optimal for every system, this is much better
> > that the current system, and would only require 5 or so extra lines
> > of code per NAPI enabled driver.
>
> Why do this when we can adjust the weight in one spot,
> namely the upper level NAPI ->poll() running loop?
>
> It can measure the overhead, how many packets processed, etc.
> and make intelligent decisions based upon that.  This is a CPU
> speed, memory speed, I/O bus speed, and link speed agnostic
> solution.
>
> The driver need not take any part in this, and the scheme will
> dynamically adjust to resource usage changes in the system.

Yes, a much better idea to do this generically.  I 100% agree with you.
