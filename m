From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v4 2/7] net: remove old tcp_optlen function
Date: Fri, 12 Mar 2010 08:21:49 -0500
Message-ID: <4B9A3FED.7060101@gmail.com>
References: <4B98D592.6040301@gmail.com> <4B98D9A2.8060603@gmail.com> <20100312002628.GB20795@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100312002628.GB20795@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/11/10 7:26 PM, Simon Horman wrote:
> On Thu, Mar 11, 2010 at 06:53:06AM -0500, William Allen Simpson wrote:
>> The tcp_optlen() function returns a potential *negative* unsigned.
>>
>> In the only two existing files using the old tcp_optlen() function,
>> clean up confusing and inconsistent mixing of both byte and word
>> offsets, and other coding style issues.  Document assumptions.
>
> IIRC, Dave already pointed out that this quoting style which singles him
> out isn't appropriate. Perhaps you should consider updating it if you want
> him to consider merging this and other changes with similar quotes in the
> changelog.
>
Thanks!  I'm primarily concerned with fixing the bug(s) introduced by
commit ab6a5bb6b28a970104a34f0f6959b73cf61bdc72 that stuffs a negative
number (after subtraction) into an unsigned result.  At the time, the
unsigned result was then stuffed back into int again.  Later folks
changed the int to u32 (in some places, inconsistently).

However, Dave's requirement that there be no TCP or IP length checking
needs to be documented.  Anybody coming to the code later will wonder why
that has not been done (eliminated from earlier versions of my patch).

Rather than spend valuable time refuting Dave and fixing all of the many
problems with TCP and IP lengths elsewhere in the tree (those are more
appropriate to other patches), just document his existing assumptions, and
move on....

Documentation/CodingStyle:
   ... put the comments at the head of the function, telling people what it
   does, and possibly WHY it does it.

The short requirement statement is in the function header comment(s).

The full quote is in the commit log.  Folks researching the "git blame"
for this patch in the future can read his rationale and hyperbole.

On Feb 17th, Dave mandated that "(see commit log)" in the source code
comments be removed:

   "We do not refer to commit log messages from the source code."

That has been done, causing the patch version to increment.


> I suggest moving the "No response from testers in 21+ weeks." to
> below the "--- " somewhere and dropping everything else except
> the Signed-off line that appears after this point.
>
Thanks!  I was unaware that putting such things after "--- " was allowed,
but checking Documentation/SubmittingPatches:

   - A marker line containing simply "---".

   - Any additional comments not suitable for the changelog.

In my next message, I'll update the change log.

Thanks again!
