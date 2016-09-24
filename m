From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not
 processed' messages
Date: Sat, 24 Sep 2016 14:06:29 -0500
Message-ID: <cef6d8da-c390-f435-7a5e-d294dfbebbfb@lwfinger.net>
References: <1474654333.1849.5.camel@perches.com>
 <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
 <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
 <1474657363.1849.9.camel@perches.com> <20160924175555.01cae6dd@endymion>
 <1474733754.23838.3.camel@perches.com>
 <49094659-662d-a902-6740-ea3d1fea6660@lwfinger.net>
 <1474738358.23838.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, Jean Delvare <jdelvare@suse.de>,
        Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474738358.23838.11.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/24/2016 12:32 PM, Joe Perches wrote:
> (adding Jes Sorensen to recipients)
>
> On Sat, 2016-09-24 at 11:35 -0500, Larry Finger wrote:
>> I have patches that makes HAL_DEF_WOWLAN be a no-op for the rest of the drivers,
>> and one that sets the enum values for that particular statement to hex values. I
>> also looked at the other large enums and decided that they never need the human
>> lookup.
>
> Hey Larry.
>
> There are many somewhat common realtek wireless drivers.
>
> Not to step on your toes, but what do you think of
> rationalizing the switch/case statements of all the
> realtek drivers in a few steps:
>
> o Reindent all the switch/case blocks to a more normal
>   kernel style (git diff -w would show no changes here)

That sounds like busy work to me, but if you want to do it, go ahead.

> o cast, spacing and parenthesis reductions
>   Lots of odd and somewhat unique styles in various
>   drivers, looks like too many individual authors without
>   a style guide / code enforcer using slightly different
>   personalized code.  Glancing at the code, it looks to be
>   similar logic, just written in different styles.

Same comment.

> o Logic changes like
>   from:
>     if (foo) func(..., bar, ...); else func(..., baz, ...);
>   to:
>     func(..., foo ? bar : baz, ...);
>   to make the case statement code blocks more consistent
>   and emit somewhat smaller object code.

I find if .. else constructs much easier to read than the cond ? xxxx : yyyy 
form. I would reject any such patches.

> o Consolidation of equivalent function spanning drivers
>   With the style only changes minimized, where possible
>   make the drivers use common ops/callback functions.

The is no question that there are similar routines in different drivers. I would 
like to place as much as possible into common routines, but I never seem to find 
the time. There are too many bugs in other things I support to consider these 
niceties.

> Is there any value in that or is Jes' work going to make
> doing any or all of this unnecessary and futile?

That is not yet determined. The only driver that is to be replaced at this point 
is rtl8192cu. Jes only has USB I/O for his driver. We are looking at adding 
SDIO, and once that is done, PCI should be possible.

Larry
