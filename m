From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fix fallout from tg3_readphy() value is zero on error
Date: Thu, 20 Jan 2005 23:36:39 -0800
Message-ID: <20050120233639.5e6088ee.davem@davemloft.net>
References: <16880.24671.640491.852938@berry.gelato.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
In-Reply-To: <16880.24671.640491.852938@berry.gelato.unsw.EDU.AU>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 12:52:31 +1100
Peter Chubb <peterc@gelato.unsw.edu.au> wrote:

> After DaveM's patch to make the `default' value returned by
> tg3_readphy() to be zero, the attached patch fixes the few cases where
> a zero changes the previous behaviur, and deletes a couple of
> initialisation to zero that are no longer necessary.

The setting to zero was to eliminate a gcc warning because
it's flow analysis in earlier versions can't tell that we
do always set it to some value.

I think it's wiser to just make sure every case checks the
tg3_read_phy() return value.  So I'll work on that.

So is your 16-way system working now with this patch on
top of the current driver?
