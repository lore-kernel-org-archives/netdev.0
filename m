From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 13:59:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512205915.GJ1397@holomorphy.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com> <20040512200305.GA16078@elte.hu> <20040512132050.6eae6905.akpm@osdl.org> <20040512203829.GI1397@holomorphy.com> <20040512134718.7e55cceb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, davidel@xmailserver.org, jgarzik@pobox.com, greg@kroah.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040512134718.7e55cceb.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

William Lee Irwin III <wli@holomorphy.com> wrote:
>> How about this?
>>  #if HZ <= 1000 && !(1000 % HZ)
>>  #define MSEC_TO_JIFFIES(m)	((1000/HZ)*(m))
>>  #define JIFFIES_TO_MSEC(j)	((j)/(1000/HZ))
>>  #elif HZ > 1000 && !(HZ % 1000)
>>  #define MSEC_TO_JIFFIES(m)	((m)/(HZ/1000))
>>  #define JIFFIES_TO_MSEC(j)	((HZ/1000)*(j))
>>  #else
>>  #define MSEC_TO_JIFFIES(m)	((HZ*(m) + 999)/1000)
>>  #define JIFFIES_TO_MSEC(j)	((1000*(j) + HZ - 1)/HZ)
>>  #endif

On Wed, May 12, 2004 at 01:47:18PM -0700, Andrew Morton wrote:
> You promise it's correct and generates good code?

Yes. Changelog:

Optimize the cases where HZ is a divisor of 1000 or vice-versa in
JIFFIES_TO_MSEC() and MSEC_TO_JIFFIES() by allowing the nonvanishing(!)
integral ratios to appear as a parenthesized expressions eligible for
constant folding optimizations.

I'll resend the #ifdef logic against Ingo's latest, which is orthogonal.


-- wli
