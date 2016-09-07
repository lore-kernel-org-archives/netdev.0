From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qed: add missing header dependencies
Date: Wed, 07 Sep 2016 14:17:41 +0200
Message-ID: <4989831.9c6WyUak3s@wuerfel>
References: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org> <DM5PR11MB1723D8845DD64E2634DBC41D97F80@DM5PR11MB1723.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Baoyou Xie <baoyou.xie@linaro.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM5PR11MB1723D8845DD64E2634DBC41D97F80@DM5PR11MB1723.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, September 7, 2016 11:37:07 AM CEST Yuval Mintz wrote:
> > We get 4 warnings when building kernel with W=1:
> > drivers/net/ethernet/qlogic/qed/qed_selftest.c:6:5: warning: no previous
> > prototype for 'qed_selftest_memory' [-Wmissing-prototypes]
> > drivers/net/ethernet/qlogic/qed/qed_selftest.c:19:5: warning: no previous
> > prototype for 'qed_selftest_interrupt' [-Wmissing-prototypes]
> > drivers/net/ethernet/qlogic/qed/qed_selftest.c:32:5: warning: no previous
> > prototype for 'qed_selftest_register' [-Wmissing-prototypes]
> > drivers/net/ethernet/qlogic/qed/qed_selftest.c:55:5: warning: no previous
> > prototype for 'qed_selftest_clock' [-Wmissing-prototypes]
> > 
> > In fact, these functions are declared in qed_selftest.h, so this patch add missing
> > header dependencies.
> > 
> > Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> 
> While I obviously have no strong objection for including qed_selftest.h
> from qed_selftest.c, I'm not sure I understand which C standard dictates
> this requirement.
> Why should a function definition [not call] be preceded by a prototype?

This rule addresses two problems:

- some functions should be marked static as they are never used outside
  of the file that declares them. Marking them static give the compiler
  better opportunities for optimization and lets you see when a function
  becomes unused, and if there is no external declaration that is often
  an indication that there are no other users.

- When a function is defined in one file and used in another, you want
  both files to include the same header that has the declaration to
  ensure that the types are identical. There are cases where the
  prototype is changed after the fact in an incompatible way, causing
  silent data corruption on some configurations but maybe not on others.

	Arnd
