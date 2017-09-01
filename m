From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] fix "ip link show dev ..." for NICs with
 many VFs
Date: Fri, 1 Sep 2017 14:16:39 -0700
Message-ID: <20170901141639.2f77d60f@xeon-e3>
References: <cover.1504283683.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1504283683.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  1 Sep 2017 18:39:06 +0200 (CEST)
Michal Kubecek <mkubecek@suse.cz> wrote:

> Two of our customers recently encountered problems with processing of large
> messages produced by kernel in response to "ip link show" for NICs with
> many (120-128) virtual functions. While some of them have been already
> addressed in recent versions of iproute2, some still persist.
> 
> Patch 1 adds check to handle the case when a message fits into the
> buffer in rtnl_talk() but not into the buffer in iplink_get().
> 
> Patch 2 increases the buffer size in iplink_get() to suffice even for
> NICs with 128 VFs. 
> 
> Note: after applying patch 2, patch 1 seems useless as both buffers have
> the same size so that the check cannot actually trigger. However, as we
> cannot guarantee they will always stay the same, I believe the check
> should still be added.
> 
> Michal Kubecek (2):
>   iplink: check for message truncation in iplink_get()
>   iplink: double the buffer size also in iplink_get()
> 
>  ip/iplink.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 

Looks like the best set of solutions to the kernel side API issue.
Applied, thanks Michal.
