From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Wed, 29 May 2013 22:02:06 +0100
Message-ID: <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
	 <20130528.233647.1209227470109213894.davem@davemloft.net>
	 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
	 <20130529194438.GY3333@ritirata.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <amwang@redhat.com>,
	<netdev@vger.kernel.org>, <horms@verge.net.au>
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56593 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966862Ab3E2VCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 17:02:10 -0400
In-Reply-To: <20130529194438.GY3333@ritirata.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-29 at 21:44 +0200, Antonio Quartulli wrote:
> On Wed, May 29, 2013 at 08:34:33PM +0100, Ben Hutchings wrote:
> > On Tue, 2013-05-28 at 23:36 -0700, David Miller wrote:
> > > From: Cong Wang <amwang@redhat.com>
> > > Date: Wed, 29 May 2013 14:09:00 +0800
> > > 
> > > > commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> > > > fields of struct skbuff) converts skb->*_header to u16,
> > > > therefore 1) we could just use 0xFFFFF instead of (__u16) ~0U
> > > > 2) some #if NET_SKBUFF_DATA_USES_OFFSET is useless now.
> > > > 
> > > > 
> > > > Cc: David S. Miller <davem@davemloft.net>
> > > > Cc: Simon Horman <horms@verge.net.au>
> > > > Signed-off-by: Cong Wang <amwang@redhat.com>
> > > 
> > > I want to use something that will either break the build or
> > > automatically work if the type changes again.
> > > 
> > > So something like "X = (typeof(X)) ~0U;".
> > 
> > I think you mean ~(typeof(X))0.
> 
> Am I wrong or you should cast the value once again, like this:
> 
> ((typeof(X))~(typeof(X))0)
> 
> because the ~ operator will implicitly cast the argument to int (if I remember
> correctly).

It will promote to at least int, but that still results in the right
value and doesn't provoke a warning.  Try this test (with -Wall
-Wextra):

#include <stdio.h>

#define ALL_ONES(v) (~(typeof(v))0)
/* #define ALL_ONES(v) (typeof(v))~0U) */

int main(void)
{
    char a = ALL_ONES(a);
    unsigned char b = ALL_ONES(b);
    short c = ALL_ONES(c);
    unsigned short d = ALL_ONES(d);
    int e = ALL_ONES(e);
    unsigned int f = ALL_ONES(f);
    long g = ALL_ONES(g);
    unsigned long h = ALL_ONES(h);
    long long i = ALL_ONES(i);
    unsigned long long j = ALL_ONES(j);

    printf("%hhx %hhx %hx %hx %x %x %lx %lx %llx %llx\n",
	   a, b, c, d, e, f, g, h, i, j);
    return 0;
}

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
