From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Limit the size of the IPV4 route hash.
Date: Fri, 10 Dec 2004 11:48:29 -0800
Message-ID: <20041210114829.034e02eb.davem@davemloft.net>
References: <20041210190025.GA21116@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, akpm@osdl.org, hirofumi@parknet.co.jp,
        torvalds@osdl.org, dipankar@ibm.com, laforge@gnumonks.org,
        bunk@stusta.de, herbert@apana.org.au, paulmck@ibm.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org, gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robin Holt <holt@sgi.com>
In-Reply-To: <20041210190025.GA21116@lnx-holt.americas.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2004 13:00:25 -0600
Robin Holt <holt@sgi.com> wrote:

> I then did some testing/experimenting with systems that are in production,
> determined the size calculation is definitely too large and then came
> to the following conclusion:
> 
> Limit the route hash size.
> http://marc.theaimsgroup.com/?l=linux-kernel&m=110260977405809&w=2
> 
> In the second, I included the patch, but did not intend this to be a
> patch submission.  Sorry for the Signed-off-by.
> 
> Where do I go from here?  I hate to just submit this as a patch without
> any other discussion.

Sometimes we have to just sit and be content with the fact that
nobody is inspired by our work enough to respond. :-)  It usually
means that people aren't too thrilled with your patch, but don't
feel any impetus to mention why.

I can definitely say that just forcing it to use 1 page is wrong.
Even ignoring your tests, your test was on a system that has 16K
PAGE_SIZE.  Other systems use 4K and 8K (and other) PAGE_SIZE
values.  This is why we make our calculations relative to PAGE_SHIFT.

Also, 1 page even in your case is (assuming you are on a 64-bit platform,
you didn't mention) going to give us 1024 hash chains.  A reasonably
busy web server will easily be talking to more than 1K unique hosts at
a given point in time.  This is especially true as slow long distance
connections bunch up.

Alexey Kuznetsov needed to use more than one page on his lowly
i386 router in Russia, and this was circa 7 or 8 years ago.

People are pretty happy with the current algorithm, and in fact
most people ask us to increase it's value not decrease it :-)
