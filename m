From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Mon, 18 May 2015 22:58:54 -0700
Message-ID: <555AD11E.5040709@cumulusnetworks.com>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com> <20150518.161916.2132217836491222672.davem@davemloft.net> <555A8209.5000306@intel.com> <20150518.234839.995695850653714769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33670 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552AbbESF64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 01:58:56 -0400
Received: by pdbqa5 with SMTP id qa5so9413555pdb.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 22:58:55 -0700 (PDT)
In-Reply-To: <20150518.234839.995695850653714769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/18/15, 8:48 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Mon, 18 May 2015 17:21:29 -0700
>
>> So how about having an error strategy sysctl field that we can set
>> at provisioning time. I think this would align to Roopa's option (b).
>> This way we can default to "transparent" mode and the users where
>> this wont work can set the error mode. This way user land software
>> stacks that work today should continue to work in both modes.
> Alert: This is not a switch provisioning issue.
>
> You can frame it like that all day, and continue to talk about
> low power cpus or other things which are completely and utterly
> irrelevant.
>
> Stop looking at how some specific piece of hardware is configured,
> and think about what actually is asking the kernel to do stuff.
>
> That's because the real issue is _semantics_ and what a Linux machine
> is expected to do when you insert a route and valid reasons why a
> route insertion can fail.
>
> That is the _only_ issue.
>
> And that has to do with what semantics _applcations_ making these
> routing change requests expect.
>
> There is nothing else that matters.
>
> And since it is an issue of what semantics those application want and
> are able to handle, that is where the request of changed behavior
> belongs.
>
> If we added your suggested sysctl, we'd have to name it
> "sysctl_break_all_my_apps_please" because that is exactly what it
> would be doing. :-)
understood. This seems to lean towards option c) where app explicitly 
requests offload with RTNH_F_OFFLOAD for every route.

from where I see, with the limitations on these boxes,
this requires every app, every `ip route` cmd running on the box to 
explicitly specify offload when running on this hardware. In which case 
having a way to specify a global system policy seemed appropriate. Hence 
the sysctl suggestion.
