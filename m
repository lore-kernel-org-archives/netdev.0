From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 7 Sep 2017 14:40:18 +0200
Message-ID: <20170907124018.deinzo3c4ice3q7n@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170907053411.GA6580@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Henrik Austad <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34624 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755353AbdIGMkX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 08:40:23 -0400
Received: by mail-wr0-f193.google.com with SMTP id k20so2698470wre.1
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 05:40:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170907053411.GA6580@sisyphus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 07:34:11AM +0200, Henrik Austad wrote:
> Also, does this mean that when you create the qdisc, you have locked the 
> bandwidth for the scheduler? Meaning, if I later want to add another 
> stream that requires more bandwidth, I have to close all active streams, 
> reconfigure the qdisc and then restart?

No, just allocate enough bandwidth to accomodate all of the expected
streams.  The streams can start and stop at will.

> So my understanding of all of this is that you configure the *total* 
> bandwith for each class when you load the qdisc and then let userspace 
> handle the rest. Is this correct?

Nothing wrong with that.
 
> In my view, it would be nice if the qdisc had some notion about streams so 
> that you could create a stream, feed frames to it and let the driver pace 
> them out. (The fewer you queue, the shorter the delay). This will also 
> allow you to enforce per-stream bandwidth restrictions. I don't see how you 
> can do this here unless you want to do this in userspace.
> 
> Do you have any plans for adding support for multiplexing streams? If you 
> have multiple streams, how do you enforce that one stream does not eat into 
> the bandwidth of another stream? AFAIK, this is something the network must 
> enforce, but I see no option of doing som here.

Please, lets keep this simple.  Today we have exactly zero user space
applications using this kind of bandwidth reservation.  The case of
wanting the kernel to police individual stream usage does not exist,
and probably never will.

For serious TSN use cases, the bandwidth needed by each system and
indeed the entire network will be engineered, and we can reasonably
expect applications to cooperate in this regard.

Thanks,
Richard
