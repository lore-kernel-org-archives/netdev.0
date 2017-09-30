From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCHv4 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Sat, 30 Sep 2017 21:54:56 +0800
Message-ID: <20170930135455.GW1754@leo.usersys.redhat.com>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-2-git-send-email-haliu@redhat.com>
 <20170929105440.7edaec1f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44384 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbdI3NzC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 30 Sep 2017 09:55:02 -0400
Content-Disposition: inline
In-Reply-To: <20170929105440.7edaec1f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
On Fri, Sep 29, 2017 at 10:54:40AM -0700, Stephen Hemminger wrote:
> 
> Doubling the number of system calls per message is not going to make
> users with 5,000,000 routes or 1000 vlans, or 10,000 tunnels happy.
> Please rethink this.

I tried to add 2500 vlans and 70,000 routes. Then show the result. The
time looks reasonable.

# ip link show | wc -l
5024

# time ip link show > /dev/null

real    0m0.218s
user    0m0.007s
sys     0m0.210s

# time iproute2/ip/ip link show > /dev/null

real    0m0.221s
user    0m0.008s
sys     0m0.212s

# time ip addr show > /dev/null

real    0m0.299s
user    0m0.094s
sys     0m0.205s

# time iproute2/ip/ip addr show > /dev/null

real    0m0.302s
user    0m0.099s
sys     0m0.202s

# ip -6 route show | wc -l
704458

# time ip -6 route show > /dev/null

real    0m5.400s
user    0m0.947s
sys     0m4.453s

# time iproute2/ip/ip -6 route show > /dev/null

real    0m5.404s
user    0m1.070s
sys     0m4.333s


Thanks
Hangbin
