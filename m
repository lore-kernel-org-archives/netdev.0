From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Fix clang warning about constant operand in
 logical operation
Date: Thu, 06 Apr 2017 23:12:25 +0200
Message-ID: <1491513145.11399.8.camel@sipsolutions.net>
References: <20170406185633.91065-1-mka@chromium.org>
         <1491505878.11399.4.camel@sipsolutions.net>
         <20170406192452.GE145051@google.com> (sfid-20170406_212455_006612_2E5FACCF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Michael Davidson <md-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Greg Hackmann <ghackmann-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170406192452.GE145051-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> (sfid-20170406_212455_006612_2E5FACCF)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-04-06 at 12:24 -0700, Matthias Kaehlcke wrote:

> I agree that the code looks worse :( I hoped to find a fix using a
> preprocessor condition but wasn't successful.

It's actually easy - just remove the 'default ""' from Kconfig, and
then the symbol won't be defined at all if it doesn't get a proper
value. Then you can ifdef the whole thing.

> Some projects (like Chrome OS) build their kernel with all warnings
> being treated as errors. Besides changing the 'offending' code the
> alternatives are to disable the warning completely or to tell clang
> not to use the builtin(s). IMO changing the code is the preferable
> solution, especially since this is so far the only occurrence of the
> warning that I have encountered.
> 
> I used goto instead of nested ifs since other functions in this file
> use the same pattern. If nested ifs are preferred I can change that.

I don't really buy either argument. The warning is simply bogus - I'm
very surprised you don't hit it with more similar macros or cases, like
for example CONFIG_ENABLED(). Try

	git grep 'IS_ENABLED(' | grep '&&'

and you'll find lots of places that seem like they should trigger this
warning.

You're advocating to make the code worse - not very significantly in
this case, but still - just to quiet a compiler warning.

johannes
