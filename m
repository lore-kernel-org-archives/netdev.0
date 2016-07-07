From: Eli Cohen <eli@mellanox.com>
Subject: RE: [PATCH] Add support for configuring Infiniband GUIDs
Date: Thu, 7 Jul 2016 21:11:45 +0000
Message-ID: <DB5PR05MB18482B444267E13DB4DB1AEAC53B0@DB5PR05MB1848.eurprd05.prod.outlook.com>
References: <1467734018-11119-1-git-send-email-eli@mellanox.com>
 <20160706210526.1e6ea9a4@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"david.laight@aculab.com" <david.laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0068.outbound.protection.outlook.com ([104.47.2.68]:35680
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751428AbcGHGoI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 02:44:08 -0400
In-Reply-To: <20160706210526.1e6ea9a4@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have just sent a new version of the patch which addresses all the comments I got.
Thanks for reviewing. Please let me know if you have any other comments.

Thanks,
Eli

-----Original Message-----
From: Stephen Hemminger [mailto:stephen@networkplumber.org] 
Sent: Wednesday, July 06, 2016 11:05 PM
To: Eli Cohen <eli@mellanox.com>
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs

On Tue,  5 Jul 2016 10:53:38 -0500
Eli Cohen <eli@mellanox.com> wrote:

>  
> +static int extract_guid(__u64 *guid, char *arg) {
> +	__u64 ret;
> +	int g[8];
> +	int err;
> +
> +	err = sscanf(arg, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
> +		     g, g + 1, g + 2, g + 3, g + 4, g + 5, g + 6, g + 7);
> +	if (err != 8)
> +		return -1;
> +
> +	ret = ((__u64)(g[0]) << 56) |
> +	      ((__u64)(g[1]) << 48) |
> +	      ((__u64)(g[2]) << 40) |
> +	      ((__u64)(g[3]) << 32) |
> +	      ((__u64)(g[4]) << 24) |
> +	      ((__u64)(g[5]) << 16) |
> +	      ((__u64)(g[6]) << 8) |
> +	      ((__u64)(g[7]));
> +	*guid = ret;
> +
> +	return 0;
> +}

I would like several things changed here.
 1. put this in generic (ie lib/utils.c) so that other places
    can use it. And rename it match other arg parsing code (ie get_guid)  2. need range checking for each piece the string, and each hex piece must be unsigned int
    suprised gcc format checks didn't bust you on this.  why not %hhx as format specifier
    
 3. arg should be const char *
 4. local variable err is really unnecessary  5. local variable ret is unnecessary, you could just assign to *guid
 
