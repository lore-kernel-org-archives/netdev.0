From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH][V2] net: sctp: fix array overrun read on sctp_timer_tbl
Date: Fri, 20 Jan 2017 14:48:20 -0200
Message-ID: <20170120164820.GA669@localhost.localdomain>
References: <20170120134542.21104-1-colin.king@canonical.com>
 <20170120.113117.1592305434267734738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: colin.king@canonical.com, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170120.113117.1592305434267734738.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 11:31:17AM -0500, David Miller wrote:
> From: Colin King <colin.king@canonical.com>
> Date: Fri, 20 Jan 2017 13:45:42 +0000
> 
> > From: Colin Ian King <colin.king@canonical.com>
> > 
> > Table sctp_timer_tbl is missing a TIMEOUT_RECONF string so
> > add this in. Also compare timeout with the size of the array
> > sctp_timer_tbl rather than SCTP_EVENT_TIMEOUT_MAX.  Also add
> > a build time check that SCTP_EVENT_TIMEOUT_MAX is correct
> > so we don't ever get this kind of mismatch between the table
> > and SCTP_EVENT_TIMEOUT_MAX in the future.
> > 
> > Kudos to Marcel Ricardo Leitner for spotting the missing string
> > and suggesting the build time sanity check.
> > 
> > Fixes CoverityScan CID#1397639 ("Out-of-bounds read")
> > 
> > Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Well, my bad... I reverted V1, that's fine.
> 
> But this patch doesn't even compile.
> 
> In file included from ./include/uapi/linux/stddef.h:1:0,
>                  from ./include/linux/stddef.h:4,
>                  from ./include/uapi/linux/posix_types.h:4,
>                  from ./include/uapi/linux/types.h:13,
>                  from ./include/linux/types.h:5,
>                  from ./include/net/sctp/sctp.h:58,
>                  from net/sctp/debug.c:41:
> net/sctp/debug.c: In function ‘sctp_tname’:
> ./include/linux/compiler.h:518:38: error: call to ‘__compiletime_assert_170’ declared with attribute error: BUILD_BUG_ON failed: SCTP_EVENT_TIMEOUT_MAX + 1 != ARRAY_SIZE(sctp_timer_tbl)
>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)

Seems you applied it on net tree, but commit that introduced the issue
(7b9438de0cd4) is still only on net-next.

I build-tested it here before acking, it worked, on top of
4567d686f5c6d955e57a3afa1741944c1e7f4033.

Colin, please respin the patch.. add the Fixes tag, fix the missing 'o'
in my name on the changelog :-) and tag the patch as net-next tree too.

Thanks,
Marcelo
