From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 13:15:19 -0300
Message-ID: <20130528161518.GC11614@optiplex.redhat.com>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com>
 <20130527224149.GA4384@electric-eye.fr.zoreil.com>
 <51A4D4AD.2010507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	riel@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51A4D4AD.2010507@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 28, 2013 at 09:00:45AM -0700, Ben Greear wrote:
> On 05/27/2013 03:41 PM, Francois Romieu wrote:
> >atomlin@redhat.com <atomlin@redhat.com> :
> >[...]
> >>Failed GFP_ATOMIC allocations by the network stack result in dropped
> >>packets, which will be received on a subsequent retransmit, and an
> >>unnecessary, noisy warning with a kernel backtrace.
> >>
> >>These warnings are harmless, but they still cause users to panic and
> >>file bug reports over dropped packets. It would be better to hide the
> >>failed allocation warnings and backtraces, and let retransmits handle
> >>dropped packets quietly.
> >
> >Linux VM may be perfect but device drivers do stupid things.
> >
> >Please don't paper over it just because some shit ends in your backyard.
> 
> We should rate-limit these messages at least.  When a system is low on memory
> the logs can quickly fill up with useless OOM messages, further slowing
> the system...
>

The real problem seems to be that more and more the network stack (drivers, perhaps)
is relying on chunks of contiguous page-blocks without a fallback mechanism to
order-0 page allocations. When memory gets fragmented, these alloc failures
start to pop up more often and they scare ordinary sysadmins out of their paints.

The big point of this change was to attempt to relief some of these warnings 
which we believed as being useless, since the net stack would recover from it
by re-transmissions.
We might have misjudged the scenario, though. Perhaps a better approach would be
making the warning less verbose for all page-alloc failures. We could, perhaps,
only print a stack-dump out, if some debug flag is passed along, either as
reference, or by some CONFIG_DEBUG_ preprocessor directive.

Rafael
 
> Ben
> 
> >
> 
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
