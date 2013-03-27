From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Is there a preferred way to get the VXLAN port number?
Date: Wed, 27 Mar 2013 11:32:59 -0700
Message-ID: <51533B5B.9030405@intel.com>
References: <51521B05.6060401@intel.com> <CAEP_g=9cXwxNE=Fxis2F_qStp1gPsjyXr2wE2agHO9rLZcquXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>, pshelar@nicira.com,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12272 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905Ab3C0SdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 14:33:00 -0400
In-Reply-To: <CAEP_g=9cXwxNE=Fxis2F_qStp1gPsjyXr2wE2agHO9rLZcquXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2013 10:26 AM, Jesse Gross wrote:
> On Tue, Mar 26, 2013 at 3:02 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> I was wondering if someone would happen to know if there is already a
>> preferred way to get the VXLAN port number for things such as
>> configuring a device to recognize a VXLAN frame on receive for parsing
>> purposes?
>>
>> I just wanted to check to make sure I hadn't missed something before
>> submitting a patch that would export a simple function for supplying the
>> vxlan_port value.
> There isn't a good way to do this at the moment.  One thing that would
> be nice though is if we can make this as generic as possible to
> different tunneling formats that might need to be configured in this
> way rather than specific to VXLAN.
>
> Another area think about is how best to supply the information to
> GRO/RPS to do the software version of these offloads.

The problem is what I am looking for is very specific to VXLAN.  I need
the port number so I can tell the hardware where to expect the VXLAN
frames to be bound to so that the hardware will recognize them and parse
them correctly.

In the case of GRO/RPS the situation is somewhat reversed.  You have a
packet with a given port number and you need to offload it.  In that
case you can probably do a socket search to determine which offload to
use and have those offloads associated with the socket via something
like the encap_rcv pointer that exists in the udp socket.

The main think I want to do is keep this simple since I would prefer to
not build up any infrastructure that will just get in the way.  My
thought for now is to just export a function to allow drivers to fetch
the port number of VXLAN.  The only downside is that it forces the VXLAN
module to load if a driver comes up with offload support, similar to how
we have been loading the 8021q module for many of the drivers that
support VLAN offloads.  Hopefully if the fixed port number approach wins
out we can simplify things by replacing the function call with a static
define. 

Thanks,

Alex
