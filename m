From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next-2.6] netns: call ops_free right after ops_exit
Date: Sun, 25 Apr 2010 07:50:34 -0700
Message-ID: <m1k4rvvb5x.fsf@fess.ebiederm.org>
References: <20100425092600.GB2866@psychotron.redhat.com>
	<20100425.025902.94572342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46606 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab0DYOuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 10:50:39 -0400
In-Reply-To: <20100425.025902.94572342.davem@davemloft.net> (David Miller's message of "Sun\, 25 Apr 2010 02\:59\:02 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Jiri Pirko <jpirko@redhat.com>
> Date: Sun, 25 Apr 2010 11:26:01 +0200
>
>> There's no need to iterate this twice. We can free net generic
>> variables right after exit is called.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
> Are you sure there are no problems with doing this?
>
> What if there are inter-net variable reference dependencies
> or something like that?
>
> I really suspect it is being done this way on purpose, but
> in the end I defer to experts like Eric B. :-)

I am pretty certain there is a problem.  My memory is fuzzy this
morning but I believe we can have rcu references between various
pieces of the networking stack for a single network namespace.  So we
need to cause all of the network namespace to exit before it is safe
to free those pieces.

Eric


