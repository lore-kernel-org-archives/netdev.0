From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Add RCU protection to assoc->transport_addr_list
Date: Thu, 06 Dec 2012 13:57:57 -0500
Message-ID: <50C0EAB5.3050303@gmail.com>
References: <16453bea94a6fc43d657139dff2ce0b5924e2a1f.1354817574.git.tgraf@suug.ch> <50C0E585.1080701@gmail.com> <20121206184433.GE16122@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:49642 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946465Ab2LFS6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 13:58:08 -0500
In-Reply-To: <20121206184433.GE16122@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2012 01:44 PM, Thomas Graf wrote:
> On 12/06/12 at 01:35pm, Vlad Yasevich wrote:
>> We may want to mark transports as dead sooner.  Probably right about
>> the time we pull them off the list.
>
> We mark it dead in sctp_transport_free() which is called at the
> end of sctp_assoc_rm_peer(). Do you want to mark it dead at the
> beginning of sctp_assoc_rm_peer() as well? (We still need to
> mark in sctp_transport_free() anyway).

Crud..  sctp_transport_free() is called directly in places...   Hmm...
the one in sctp_association_free() may need to be list_del_rcu()...

Ok, we can leave the dead handling the way it is..

-vlad

>
>> When displaying, we may want to
>> look at transport->dead, and skip them.  It will reduce the probability
>> that we would be looking at a transport that's about to go away.
>
> Agreed.
>
