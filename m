From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.4.22-pre1][NET] timer cleanups
Date: Sat, 30 Aug 2003 20:33:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830203311.0b8c0807.davem@redhat.com>
References: <1062258097.8532.26.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay-rc@naturesoft.net>
In-Reply-To: <1062258097.8532.26.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Aug 2003 21:11:37 +0530
Vinay K Nallamothu <vinay-rc@naturesoft.net> wrote:

> This patch does the following timer code cleanup:
> 
> 1. Change del_timer/add_timer to mod_timer
> 2. Use static timer initialisation wherever applicable

I'm not accepting this.  In particular, the ip6_flowlabel.c
change is a bad idea because the code remains racey.  Someone
submitted a similar move to mod_timer() for ip6_flowlabel
earlier this week so see my comments there about what needs
to occur to fix the code properly.

Just blindly doing these kinds of conversions to mod_timer()
is foolhardy.  You need to apply some brains to it to make
sure you really are getting rid of whatever potential races
exist in the code.  And in the ip6_flowlabel.c case things are
as buggy as they were before.
