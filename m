From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 4.11] genetlink: fix counting regression on
 ctrl_dumpfamily()
Date: Wed, 22 Mar 2017 15:39:15 -0700 (PDT)
Message-ID: <20170322.153915.842535433384366274.davem@davemloft.net>
References: <1490195313-13272-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        xose.vazquez-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
        johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490195313-13272-1-git-send-email-sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 22 Mar 2017 16:08:33 +0100

> Commit 2ae0f17df1cd ("genetlink: use idr to track families") replaced
> 
> 	if (++n < fams_to_skip)
> 		continue;
> into:
> 
> 	if (n++ < fams_to_skip)
> 		continue;
> 
> This subtle change cause that on retry ctrl_dumpfamily() call we omit
> one family that failed to do ctrl_fill_info() on previous call, because
> cb->args[0] = n number counts also family that failed to do
> ctrl_fill_info().
> 
> Patch fixes the problem and avoid confusion in the future just decrease
> n counter when ctrl_fill_info() fail.
> 
> User visible problem caused by this bug is failure to get access to
> some genetlink family i.e. nl80211. However problem is reproducible
> only if number of registered genetlink families is big enough to
> cause second call of ctrl_dumpfamily().
> 
> Cc: Xose Vazquez Perez <xose.vazquez-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Fixes: 2ae0f17df1cd ("genetlink: use idr to track families")
> Signed-off-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied and queued up for -stable, thanks.
