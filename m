From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Mon, 18 May 2015 17:21:29 -0700
Message-ID: <555A8209.5000306@intel.com>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com> <20150518.161916.2132217836491222672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, john.fastabend@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56255 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbbESAVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 20:21:31 -0400
In-Reply-To: <20150518.161916.2132217836491222672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2015 01:19 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Sun, 17 May 2015 16:42:05 -0700
> 
>> On most systems where you can offload routes to hardware,
>> doing routing in software is not an option (the cpu limitations
>> make routing impossible in software).
> 
> You absolutely do not get to determine this policy, none of us
> do.
> 
> What matters is that by default the damn switch device being there
> is %100 transparent to the user.
> 
> And the way to achieve that default is to do software routes as
> a fallback.
> 

Although this is not really usable for a class of switches this way,
as noted above.

> I am not going to entertain changes of this nature which fail
> route loading by default just because we've exceeded a device's
> HW capacity to offload.
> 
> I thought I was _really_ clear about this at netdev 0.1

So how about having an error strategy sysctl field that we can set
at provisioning time. I think this would align to Roopa's option (b).
This way we can default to "transparent" mode and the users where
this wont work can set the error mode. This way user land software
stacks that work today should continue to work in both modes.

.John
