From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] ipv4: Add FIB nexthop exceptions.
Date: Tue, 17 Jul 2012 07:25:34 -0700 (PDT)
Message-ID: <20120717.072534.1265804777758072167.davem@davemloft.net>
References: <20120717.061435.1733209287175819043.davem@davemloft.net>
	<1342533605.2626.680.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761Ab2GQOZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 10:25:37 -0400
In-Reply-To: <1342533605.2626.680.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jul 2012 16:00:05 +0200

> On Tue, 2012-07-17 at 06:14 -0700, David Miller wrote:
>> In a regime where we have subnetted route entries, we need a way to
>> store persistent storage about destination specific learned values
>> such as redirects and PMTU values.
>> 
>> This is implemented here via nexthop exceptions.
>> 
>> The initial implementation is a simple linked list, and can be
>> expanded to a hash table when it is shown to be justified.
> 
> Say a typical host uses a single default route, I am trying to convince
> myself it can really use a simple linked list ?
> 
> Arent PMTU entries added by messages coming from untrusted sources ?

They are trusted when we validate them at the socket layer, at least
as is done for TCP.

I totally agree that we'll need to adjust the list into something more
sophisticated, but that's an implementation detail rather than
something that requires the actual infrastructure to be redone.
