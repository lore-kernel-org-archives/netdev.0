From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Question w.r.t debugfs / netdevice pass-through IOCTL
Date: Thu, 21 Oct 2010 13:22:01 -0700
Message-ID: <4CC0A0E9.9090903@intel.com>
References: <F363E7AC84E1B646A0358B281A46F4AEABA0FFCC68@HQ1-EXCH03.corp.brocade.com> <20101020211900.79b8336f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Debashis Dutt <ddutt@Brocade.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63400 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755482Ab0JUUWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 16:22:03 -0400
In-Reply-To: <20101020211900.79b8336f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2010 9:19 PM, Stephen Hemminger wrote:
> On Wed, 20 Oct 2010 20:26:50 -0700
> Debashis Dutt <ddutt@Brocade.COM> wrote:
> 
>> Hi, 
>>
>> For the Brocade 10G Ethernet driver (bna) we want to implement a set of operations which is not supported by current tools like ethtool. 
>>
>> Examples of such operations would be 
>>        a) Queries related to CEE, if the link is CEE.

Assuming CEE is Converged Enhanced Ethernet here.

For CEE queries please consider using the dcbnl interface in /net/dcb/dcbnl.c. If
it is missing an interface that would be useful to all DCB devices we could
entertain adding it. Also this way DCB queries will work with existing tools that
query these things lldpad/dcbtool.

The things you would want to know about a CEE device should be about the same
regardless of the hardware in use lets try to use a single interface and avoid
private interfaces.

Thanks,
John.

>>        b) Get traces from firmware.
> 
>>
>> I was wondering what would be right approach to take here:
>>                 a) use debugfs (like the Chelsio cxgb4 driver)
> Works as long as they are really debug operations. The debugfs isn't always
> available, and support should be a config option for your driver.
> 
>>                 b) use SIOCDEVPRIVATE for the pass through IOCTL defined in
>>                     struct net_device_ops{}
> 
> The problem with ioctl is it doesn't work for 32 bit user space
> compatiablity. The ioctl compat layer does not have enough context
> to translate SIOCDEVPRIVATE
> 
>>                     As per comments in the header file, b) should not be used
>>                     since this IOCTL is supposed to be deprecated.
>>                 c) use procfs / sysfs (these may not scale, in our opinion)
> 
> Although less common, there were drivers putting things in /proc/net/xxx/ethX
> 
> 
> 

