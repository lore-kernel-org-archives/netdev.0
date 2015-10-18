From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 3.19 and earlier] fib_rules: Fix dump_rules() not to exit
 early
Date: Sat, 17 Oct 2015 17:12:37 -0700
Message-ID: <20151018001237.GD18971@kroah.com>
References: <1444066168-5566-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Roland Dreier <roland@kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444066168-5566-1-git-send-email-roland@kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 05, 2015 at 10:29:28AM -0700, Roland Dreier wrote:
> From: Roland Dreier <roland@purestorage.com>
> 
> Backports of 41fc014332d9 ("fib_rules: fix fib rule dumps across
> multiple skbs") introduced a regression in "ip rule show" - it ends up
> dumping the first rule over and over and never exiting, because 3.19
> and earlier are missing commit 053c095a82cf ("netlink: make
> nlmsg_end() and genlmsg_end() void"), so fib_nl_fill_rule() ends up
> returning skb->len (i.e. > 0) in the success case.
> 
> Fix this by checking the return code for < 0 instead of != 0.
> 
> Signed-off-by: Roland Dreier <roland@purestorage.com>
> ---
> Hi, this is needed for all stable trees earlier than 4.0 that have
> picked up 41fc014332d9; so far looks like at least 3.10.y and 3.14.y
> have made such releases.

Thanks for this, now applied to 3.10 and 3.14-stable trees.

greg k-h
