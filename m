From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 20 Mar 2014 07:49:07 -0400
Message-ID: <532AD5B3.6020205@mojatatu.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:40435 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281AbaCTLtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 07:49:19 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so16969416igc.0
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 04:49:19 -0700 (PDT)
In-Reply-To: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On 03/19/14 11:33, Jiri Pirko wrote:
> This is just an early draft, RFC. I wanted to post this early to get the
> feedback as soon as possible.
>
> The basic idea is to introduce a generic infractructure to support various
> switch chips in kernel. Also the idea is to benefit of currently existing
> Open vSwitch userspace infrastructure.
>


I think the abstraction should be a netdev and to be specific the
bridge - not openvswitch. Our current tools like ifconfig, iproute2,
bridge etc should continue to work.
In my experience, it is sufficient to model a switch after the linux
bridge at the basic level if the starting point is
L2 (which is the lowest common denominator).
And then you add capabilities that different chips expose.
Not every chip can do vxlan, flows etc. And we already know how
to abstract those out.
My  experience on top of broadcom chips is the approach i described
works rather well.

Additionally, note:
We do have L2 devices that offload in the kernel
(refer to DSA, posting earlier from the openwrt guys, and
the intel devices which do VDMQ etc). I am now counting we have 5
different approaches if we add yours.

cheers,
jamal
