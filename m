From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] net: Allow no-cache copy from user on transmit
Date: Wed, 23 Mar 2011 12:48:05 -0700
Message-ID: <AANLkTi=X8RWFF6ktAxjUTr3iVHPBNOWFpjpuLDzo-06O@mail.gmail.com>
References: <alpine.DEB.2.00.1103231003120.16608@pokey.mtv.corp.google.com>
	<AANLkTi=Tg4jW7hZZ43E71GNi+d8JWMJQcv3ExZA6zJQW@mail.gmail.com>
	<20110323122544.032fb543@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:58364 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932576Ab1CWTsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:48:10 -0400
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p2NJm9ii024637
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 12:48:09 -0700
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by hpaq5.eem.corp.google.com with ESMTP id p2NJm6js003416
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 12:48:07 -0700
Received: by pzk27 with SMTP id 27so1349387pzk.13
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 12:48:06 -0700 (PDT)
In-Reply-To: <20110323122544.032fb543@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Isn't nocache DMA a function of the I/O architecture not a function
> of the device driver? Shouldn't it be handled at PCI level somehow
> with considerations of CPU arch and quirks? Doesn't it make sense for
> non-network traffic as well.
>
> Hate to hold up a good optimization while waiting for a general
> solution, but commiting to an API prematurely would be bad as well.
>

There's an implicit assumption in the patch that if somewhere below
the copyfromuser the data is touched it would be more efficient to
copy through the cache than bypass it.  Whether the data is touched is
an attribute of the device and hence the per device control.

Now that I think about it, I don't really know what the actual
performance impact is to bypass cache copy and then touch the data.
I'd be interested to know if anyone has data on that, else I'll try to
contrive some benchmark numbers.

Tom

>
>
> --
>
