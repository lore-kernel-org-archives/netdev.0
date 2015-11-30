From: "Singhai, Anjali" <anjali.singhai@intel.com>
Subject: RE: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 21:42:37 +0000
Message-ID: <C40BE8378EF49C44B9184714DBC8EF2993A70447@ORSMSX115.amr.corp.intel.com>
References: <CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
	<20151123171103.00007699@unknown>
	<CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
 <20151129.222243.2290113258075462913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"jesse@kernel.org" <jesse@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Patil, Kiran" <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>,
	"tom@herbertland.com" <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42130 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595AbbK3Vmo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 16:42:44 -0500
In-Reply-To: <20151129.222243.2290113258075462913.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Sunday, November 29, 2015 7:23 PM
To: tom@herbertland.com
Cc: Brandeburg, Jesse <jesse.brandeburg@intel.com>; Singhai, Anjali <anjali.singhai@intel.com>; jesse@kernel.org; netdev@vger.kernel.org; Patil, Kiran <kiran.patil@intel.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 24 Nov 2015 09:32:11 -0800

>>
>> FWIW, I've brought the issue to the attention of the architects here, 
>> and we will likely be able to make changes in this space.  Intel 
>> hardware (as demonstrated by your patches) already is able to deal 
>> with this de-ossification on transmit.  Receive is a whole different beast.
>>
> Please provide the specifics on why "Receive is a whole different 
> beast.". Generic receive checksum is already a subset of the 
> functionality that you must have implement to support the protocol 
> specific offloads. All the hardware needs to do is calculate the 1's 
> complement checksum of the packet and return the value on the to the 
> host with that packet. That's it. No parsing of headers, no worrying 
> about the pseudo header, no dealing with any encapsulation. Just do 
> the calculation, return the result to the host and the driver converts 
> this to CHECKSUM_COMPLETE. I find it very hard to believe that this is 
> any harder than specific support the next protocol du jour.

The reason for receive being different than transmit is, on TX side driver can provide the meta data for where the checksum field is and what is the length that needs to be check summed to the HW on a per packet basis. On Rx the HW parser has to parse the packet to identify the tunnel type and based on that figure out the checksum locations and length in the packet, so definitely HW has to parse the packet and it can parse only based on next header type information or in case of udp tunnels based on udp port mapping to a particular protocol. I am not sure why you say it doesn't need to parse the packet, maybe I am miss- understanding something.  Although it's not difficult to reduce protocol ossification on the RX side but it is certainly different and particularly in case of udp-tunnels i
 t needs the port to protocol mapping.

+1
