From: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
	net/ipv{4,6}/route.c
Date: Sun, 10 Jun 2012 11:16:34 +0800
Message-ID: <20120610031634.GA10032@localhost>
References: <20120609.163202.516027044484907548.davem@davemloft.net>
	<20120610015832.GA9175@localhost>
	<20120609.190451.182034193302304295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120609.190451.182034193302304295.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 09, 2012 at 07:04:51PM -0700, David Miller wrote:
> From: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> Date: Sun, 10 Jun 2012 09:58:32 +0800
> 
> > It triggers some warnings:
> > 
> > WARNING: net/ipv6/ipv6.o(.text+0x1049c): Section mismatch in reference from the function ip6_route_cleanup() to the variable .init.data:ipv6_inetpeer_ops
> 
> This should fix it:

Yes it worked.

Tested-by: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

In long run, such build-fix patches can also be auto tested and
reported, somehow in this way. You just create a temporary branch
named "0day-XXXXXX" and push the build-fix patch there. After a while
my robot script will pull and build test it. When finished, it will
recognize the "0day" pattern in the branch name and then
*unconditionally* report back.

"unconditionally" means it will

- report build failure as well as build success
- report new error/warnings as well as old ones

Upon receiving the success/failure notification, you can then proceed
to either merge the commit to the main branch, or update the commit in
place to restart the test. This should work much more fluently than
waiting for me to manually test some emailed patch. Not only I may be
sleeping at the time, but also I'm sending out build failure reports
almost *every day*. It would be a burden for me to manually test out
fixes every day...

Thanks,
Fengguang
