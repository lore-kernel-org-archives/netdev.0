From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 4/5] e1000e: Separate signaling for link check/link up
Date: Fri, 21 Jul 2017 14:50:02 -0400
Message-ID: <20170721185002.GV18556@csclub.uwaterloo.ca>
References: <20170721160937.GA22632@csclub.uwaterloo.ca>
 <20170721183627.13373-1-bpoirier@suse.com>
 <20170721183627.13373-4-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170721183627.13373-4-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2017 at 11:36:26AM -0700, Benjamin Poirier wrote:
> Lennart reported the following race condition:
> 
> \ e1000_watchdog_task
>     \ e1000e_has_link
>         \ hw->mac.ops.check_for_link() === e1000e_check_for_copper_link
>             /* link is up */
>             mac->get_link_status = false;
> 
>                             /* interrupt */
>                             \ e1000_msix_other
>                                 hw->mac.get_link_status = true;
> 
>         link_active = !hw->mac.get_link_status
>         /* link_active is false, wrongly */
> 
> This problem arises because the single flag get_link_status is used to
> signal two different states: link status needs checking and link status is
> down.
> 
> Avoid the problem by using the return value of .check_for_link to signal
> the link status to e1000e_has_link().
> 
> Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

This too seems potentially -stable worthy, although with patch 5, the
problem becomes much much less likely to occur.

-- 
Len Sorensen
