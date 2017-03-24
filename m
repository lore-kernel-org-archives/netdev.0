From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2 5/8] net: Track start of busy loop instead
 of when it should end
Date: Thu, 23 Mar 2017 18:24:42 -0700
Message-ID: <1490318682.9687.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
         <20170323213742.12615.85793.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170323213742.12615.85793.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-23 at 14:37 -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 

> The last bit I changed is to move from using a shift by 10 to just using
> NSEC_PER_USEC and using multiplication for any run time calculations and
> division for a few compile time ones.  This should be more accurate and
> perform about the same on most architectures since modern CPUs typically
> handle multiplication without too much overhead.


busy polling thread can be preempted for more than 2 seconds.

Using usec instead of nanoseconds gave us 3 orders of magnitude cushion.

We do not need nsec accuracy for busy polling users, if this restricts
range and usability under stress.
