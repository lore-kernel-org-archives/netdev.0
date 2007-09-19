From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 16:05:20 -0700
Message-ID: <20070919160520.709a6819@freepuppy.rosehill.hemminger.net>
References: <20070918.151528.84360712.davem@davemloft.net>
	<20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
	<20070919.150755.38714639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41823 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759264AbXISXFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:05:51 -0400
In-Reply-To: <20070919.150755.38714639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 15:07:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 19 Sep 2007 14:59:00 -0700
> 

...

> > > +static int niu_wait_bits_clear_mac(struct niu *np, unsigned long reg, u64 bits,
> > > +				   int limit, int delay)
> > > +{
> > > +	BUILD_BUG_ON(limit <= 0 || delay < 0);
> > 
> > There is no way compiler can evaluate limit or delay.
> 
> Check the callers, they all pass contant values.

GCC is not as smart as you think... Try the following test:
--------------------
#include <stdio.h>

#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))
#define ENODEV -10

static int niu_wait_bits_clear_mac(void *np, unsigned long reg,
				   int limit, int delay)
{
	BUILD_BUG_ON(limit <= 0 || delay < 0);

	if (limit < 0)
		return -ENODEV;
	while (limit > 0)
		sleep(delay);
	
	return 0;
}

int main(int argc, char **argv) {
	printf("start\n");
	niu_wait_bits_clear_mac(NULL, 0, 10, 1);

	niu_wait_bits_clear_mac(NULL, 0, -1, 0);
	
	niu_wait_bits_clear_mac(NULL, 0, 0, -1);
	return 0;
}
