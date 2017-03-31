From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ath6kl: Add __printf verification to ath6kl_dbg
Date: Fri, 31 Mar 2017 10:45:07 -0700
Message-ID: <1490982307.27353.14.camel@perches.com>
References: <e4556e95a5935f591fdff67c6fb2f7ef5c7fd04f.1490914618.git.joe@perches.com>
         <CALLGbR+szcYFdbdh_0qBS4B_X6YQvU6CDFpR-XZvc7p3zA+ZdQ@mail.gmail.com>
         <1490981039.27353.12.camel@perches.com>
         <CALLGbRJRstmGL-o2ds4SQ5hDNVBcfP23JnRt5qRrVg-ix-8Hiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Steve deRosier <derosier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALLGbRJRstmGL-o2ds4SQ5hDNVBcfP23JnRt5qRrVg-ix-8Hiw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-31 at 10:34 -0700, Steve deRosier wrote:
> On Fri, Mar 31, 2017 at 10:23 AM, Joe Perches <joe@perches.com> wrote:
> > On Fri, 2017-03-31 at 10:19 -0700, Steve deRosier wrote:
> > > On Thu, Mar 30, 2017 at 3:57 PM, Joe Perches <joe@perches.com> wrote:
> > > > Fix fallout too.
> > 
> > []
> > > My only question is why bother doing a format check on something
> > > that's going to be compiled out anyway?
> > 
> > To avoid introducing defects when writing new code
> > and not using the debugging code path.
> > 
> 
> Fair enough. And I totally agree with the defensive programming here
> in that case and feel it's worth the tradeoff (if indeed there really
> is any cost, I'm unsure what gcc actually does in this instance).
> 
> For sake of discussion though - shouldn't anything not using the debug
> code path in this case always be of the form that compiles out? ie
> would be empty functions intended here just to make compilation work
> and the code that depends on it simpler? Thus, there really should
> never be a risk of introducing said defects. If any "real" code were
> put in that else clause, that'd be a big red-flag in the review of
> said hypothetical patch.

Generically, all debugging forms should strive to avoid side-effects.

For instance, look at no_printk/pr_debug in the #ifndef DEBUG paths.

It uses if (0) to avoid compilation of arguments that might be
function calls or volatile accesses and so might have side-effects
altogether.

include/linux/printk.h-/*
include/linux/printk.h- * Dummy printk for disabled debugging statements to use whilst maintaining
include/linux/printk.h- * gcc's format checking.
include/linux/printk.h- */
include/linux/printk.h:#define no_printk(fmt, ...)                              \
include/linux/printk.h-({                                                       \
include/linux/printk.h- do {                                            \
include/linux/printk.h-         if (0)                                  \
include/linux/printk.h-                 printk(fmt, ##__VA_ARGS__);     \
include/linux/printk.h- } while (0);                                    \
include/linux/printk.h- 0;                                              \
include/linux/printk.h-})
i
