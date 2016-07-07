From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] Add support for configuring Infiniband GUIDs
Date: Thu, 7 Jul 2016 10:08:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4F2479@AcuExch.aculab.com>
References: <1467734018-11119-1-git-send-email-eli@mellanox.com>
 <20160706210526.1e6ea9a4@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
	Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:63958 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbcGGKKw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 06:10:52 -0400
In-Reply-To: <20160706210526.1e6ea9a4@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger
> Sent: 07 July 2016 05:05
> On Tue,  5 Jul 2016 10:53:38 -0500
> Eli Cohen <eli@mellanox.com> wrote:
> 
> >
> > +static int extract_guid(__u64 *guid, char *arg)
> > +{
> > +	__u64 ret;
> > +	int g[8];
> > +	int err;
> > +
> > +	err = sscanf(arg, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
> > +		     g, g + 1, g + 2, g + 3, g + 4, g + 5, g + 6, g + 7);
> > +	if (err != 8)
> > +		return -1;
> > +
> > +	ret = ((__u64)(g[0]) << 56) |
> > +	      ((__u64)(g[1]) << 48) |
> > +	      ((__u64)(g[2]) << 40) |
> > +	      ((__u64)(g[3]) << 32) |
> > +	      ((__u64)(g[4]) << 24) |
> > +	      ((__u64)(g[5]) << 16) |
> > +	      ((__u64)(g[6]) << 8) |
> > +	      ((__u64)(g[7]));
> > +	*guid = ret;
> > +
> > +	return 0;
> > +}
> 
> I would like several things changed here.
>  1. put this in generic (ie lib/utils.c) so that other places
>     can use it. And rename it match other arg parsing code (ie get_guid)
>  2. need range checking for each piece the string, and each hex piece must be unsigned int
>     suprised gcc format checks didn't bust you on this.  why not %hhx as format specifier
> 
>  3. arg should be const char *
>  4. local variable err is really unnecessary
>  5. local variable ret is unnecessary, you could just assign to *guid

I'd suggest not using sscanf, but using the kernel equivalent of strtoul()
(or even just looking for [0-9a-fA-F] directly).
sscanf() can bite you in all sorts of unexpected ways.

	David
