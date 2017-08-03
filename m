From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] iplink: Notify user if EEXIST error might be
 spurious
Date: Thu, 3 Aug 2017 15:52:52 -0700
Message-ID: <20170803155252.79050c16@xeon-e3>
References: <20170801172747.2817-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34920 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdHCWwy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:52:54 -0400
Received: by mail-pg0-f54.google.com with SMTP id v189so413957pgd.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 15:52:54 -0700 (PDT)
In-Reply-To: <20170801172747.2817-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Aug 2017 19:27:47 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Back in the days when RTM_NEWLINK wasn't yet implemented, people had to
> rely upon kernel modules to create (virtual) interfaces for them. The
> number of those was usually defined via module parameter, and a sane
> default value was chosen. Now that iproute2 allows users to instantiate
> new interfaces at will, this is no longer required - though for
> backwards compatibility reasons, we're stuck with both methods which
> collide at the point when one tries to create an interface with a
> standard name for a type which exists in a kernel module: The kernel
> will load the module, which instantiates the interface and the following
> RTM_NEWLINK request will fail since the interface exists already. For
> instance:
> 
> | # lsmod | grep dummy
> | # ip link show | grep dummy0
> | # ip link add dummy0 type dummy
> | RTNETLINK answers: File exists
> | # ip link show | grep -c dummy0
> | 1
> 
> There is no race-free solution in userspace for this dilemma as far as I
> can tell, so try to detect whether a user might have run into this and
> notify that the given error message might be irrelevant.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

There is already a workable solution. There is already module parameters to block autocreation
in bonding and dummy network device. The others should have it as well.

This patch just seems like creating more clutter.
