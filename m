From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/10] drivers/net/can/flexcan.c: add missing clk_put
Date: Wed, 01 Jun 2011 13:11:36 -0700 (PDT)
Message-ID: <20110601.131136.391831410750786951.davem@davemloft.net>
References: <1306948213-20767-4-git-send-email-julia@diku.dk>
	<1306949175.32125.20.camel@Joe-Laptop>
	<Pine.LNX.4.64.1106012207260.5871@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, wg@grandegger.com,
	kernel-janitors@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1106012207260.5871@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Wed, 1 Jun 2011 22:08:46 +0200 (CEST)

> On Wed, 1 Jun 2011, Joe Perches wrote:
> 
>> On Wed, 2011-06-01 at 19:10 +0200, Julia Lawall wrote:
>> > The failed_get label is used after the call to clk_get has succeeded, so it
>> > should be moved up above the call to clk_put.
>> []
>> > diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
>> []
>> > @@ -978,8 +978,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
>> >   failed_map:
>> >  	release_mem_region(mem->start, mem_size);
>> >   failed_req:
>> > -	clk_put(clk);
>> >   failed_get:
>> > +	clk_put(clk);
>> >   failed_clock:
>> >  	return err;
>> 
>> If this is correct, it might be better to rename all the
>> uses of failed_req to failed_get and delete label failed_req.
> 
> As I replied to Walter Harms, I believe it is correct, because I don't see 
> anything in the called functions that needs to be freed.  I can redo the 
> patch to eliminate the label.

Please do.
