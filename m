From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 2/2] macvtap: Implement multiqueue for macvtap driver
Date: Wed, 4 Aug 2010 16:54:45 +0200
Message-ID: <201008041654.45982.arnd@arndb.de>
References: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com> <AANLkTimgSg+iFouARaFv8X6S8d2e6L+ffkZkoOaja20R@mail.gmail.com> <OF3D82198C.4738EB40-ON65257775.0046DC1D-65257775.004997E7@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, bhutchings@solarflare.com,
	davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	therbert@google.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:55490 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932897Ab0HDOy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 10:54:58 -0400
In-Reply-To: <OF3D82198C.4738EB40-ON65257775.0046DC1D-65257775.004997E7@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 August 2010, Krishna Kumar2 wrote:
> 1. Use % to find the slot.
> 2. If slot is null - I don't want to handle this since I think
>    it is better to return NULL if some fd's were closed by user.
>    Typically this should never happen since fd's are opened and
>    passed to vhost for setting up the backend. So if they are
>    closed, then I think NULL is OK.
> 

Having some of the file descriptors closed is not something that
we should optimize for, but then again it makes sense to still
keep going, mostly for consistency reasons: One day we may
have a use case for a dynamically growing and shrinking set of
queues. Falling back to the first queue is probably ok, we can
always add optimizations when this becomes a real use case.

	Arnd
