From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: don't change gso data on clones
Date: Wed, 11 Feb 2015 22:17:19 -0500
Message-ID: <54DC1B3F.8000507@oracle.com>
References: <54DB5711.3040705@oracle.com>	 <1423662993.4847.19.camel@edumazet-glaptop2.roam.corp.google.com>	 <54DB92CD.1070309@oracle.com> <1423709570.4847.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26677 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbbBLDR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:17:28 -0500
In-Reply-To: <1423709570.4847.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, I've seen that patch. The bug I'm fixing has the same symptoms,
but the mangling is being done by the sunvnet driver and the fix is
the same-- don't mangle packets that are cloned (and unclone them if you
need to mangle them).

The original sunvnet code changed gso_size temporarily, but that still
had a race where TCP could see the driver-modified gso_size with low probability
and end up with a negative packets-in-flight.

The unclone removes that bug, created (by me) after your fix, but in the sunvnet driver
with the addition of TSO support.

						+-DLS

On 02/11/2015 09:52 PM, Eric Dumazet wrote:

> 
> Well, we had a very hard to find bug in TCP stack, I want to make sure
> we fixed all relevant points.
> 
> commit c52e2421f7368fd36cbe330d2cf41b10452e39a9
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Oct 15 11:54:30 2013 -0700
> 
>     tcp: must unclone packets before mangling them
>     
>     TCP stack should make sure it owns skbs before mangling them.
...
