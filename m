From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Thu, 02 Dec 2010 05:40:28 -0500
Message-ID: <1291286428.2183.494.camel@mojatatu>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, tgraf@infradead.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:64261 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab0LBKko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 05:40:44 -0500
Received: by yxt3 with SMTP id 3so3485976yxt.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 02:40:44 -0800 (PST)
In-Reply-To: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-01 at 10:27 -0800, John Fastabend wrote:
> Add support to return IFLA_TC qos settings to the 'ip link'
> command. The following sets the number of traffic classes
> supported in HW and builds a priority map.
> 
> #ip link set eth3 tc num 8 map 0 1 2 3 4 5 6 7 0 0 0 0 0 0 0 0
> 
> With the output from 'ip link' showing maps for interfaces with
> the ability to use HW traffic classes.

2 comments apply to the kernel patches as well - but easier to point
out here.

1) IMO, this looks like the wrong interface to use. 
Was there any reason not to use tc and instead having it show
itself embedded within "ip" abstraction? 
Example, this would suit your intent:
tc qdisc add dev eth3 hware-kinda-8021q-sched num 8 map blah bleh

You can then modify individual classes of traffic with "tc class".

[There are plenty of other chips (switching chips for example) that
implement a variety different hardware schedulers, hence the
"hardware-kinda-8021q-sched" above]

2) How does this mapping in hardware correlate to the software side
mapping? When packets of class X make it off the hardware and hit
the stack are they still going to get the same treatment as they
would have in h/ware?


cheers,
jamal

