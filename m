From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not
 processed' messages
Date: Sat, 24 Sep 2016 10:32:38 -0700
Message-ID: <1474738358.23838.11.camel@perches.com>
References: <1474654333.1849.5.camel@perches.com>
         <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
         <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
         <1474657363.1849.9.camel@perches.com> <20160924175555.01cae6dd@endymion>
         <1474733754.23838.3.camel@perches.com>
         <49094659-662d-a902-6740-ea3d1fea6660@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Jean Delvare <jdelvare@suse.de>,
        Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <49094659-662d-a902-6740-ea3d1fea6660@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(adding Jes Sorensen to recipients)

On Sat, 2016-09-24 at 11:35 -0500, Larry Finger wrote:
> I have patches that makes HAL_DEF_WOWLAN be a no-op for the rest of the drivers, 
> and one that sets the enum values for that particular statement to hex values. I 
> also looked at the other large enums and decided that they never need the human 
> lookup.

Hey Larry.

There are many somewhat common realtek wireless drivers.

Not to step on your toes, but what do you think of
rationalizing the switch/case statements of all the
realtek drivers in a few steps:

o Reindent all the switch/case blocks to a more normal
  kernel style (git diff -w would show no changes here)

o cast, spacing and parenthesis reductions
  Lots of odd and somewhat unique styles in various
  drivers, looks like too many individual authors without
  a style guide / code enforcer using slightly different
  personalized code.  Glancing at the code, it looks to be
  similar logic, just written in different styles.

o Logic changes like
  from:
    if (foo) func(..., bar, ...); else func(..., baz, ...);
  to:
    func(..., foo ? bar : baz, ...);
  to make the case statement code blocks more consistent
  and emit somewhat smaller object code.

o Consolidation of equivalent function spanning drivers
  With the style only changes minimized, where possible
  make the drivers use common ops/callback functions.

Is there any value in that or is Jes' work going to make
doing any or all of this unnecessary and futile?
