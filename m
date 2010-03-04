From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros,
 recursive vsnprintf
Date: Thu, 4 Mar 2010 14:38:37 -0800
Message-ID: <20100304143837.af39845d.akpm@linux-foundation.org>
References: <cover.1267682641.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1267682641.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  3 Mar 2010 22:27:21 -0800
Joe Perches <joe@perches.com> wrote:

> (Typo'ed Linus' email address, added Greg KH and netdev)

What is the networking significance here?

> dev_<level> macros use a lot of repetitive string space.
> 
> Eliminate the string prefixes and function arguments from all the macro uses
> and consolidate them in functions.
> 
> This patchset saves about 60K.
> 
> This implementation also adds the ability to use a struct va_format to
> emit a format string along with va_list arguments.
> 
> This %pV implementation should not be used without a wrapper that
> does printf argument verification like the dev_<level> functions.
> 
> Inspired a bit by Nick Andrew's patches and Linus' comments in December 2008
> http://lkml.org/lkml/2008/12/6/15
> http://lkml.org/lkml/2008/12/6/101
> 

Looks like a reasonable approach, although I didn't check how much
additional stack the recursion will take.  Bear in mind that printk()
can be called from super-deep contexts.

What would I need to do to make it recur more than once?  Include a %pV
in a string, like dev_printk("%s", %%pV")?
