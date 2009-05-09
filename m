From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: ports beeing reused too fast
Date: Sat, 9 May 2009 16:11:19 +0300
Message-ID: <200905091611.20321.opurdila@ixiacom.com>
References: <200905082311.09414.opurdila@ixiacom.com> <4A052991.5040009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27038 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751553AbZEINMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 09:12:30 -0400
In-Reply-To: <4A052991.5040009@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 May 2009 09:58:25 Eric Dumazet wrote:

> > I've looked over the  code and it looks right, so maybe net_random() is
> > not random enough? Or maybe there are side effects because of the %
> > port_range?
>
> Random is random :)
> Probability a port can be reused pretty fast is not nul.
>

Thinking again about it... you are right :)

> So yes, behavior you discovered is expected, when we switched port
> selection from a sequential one (not very secure btw) to a random one.
>
> Any strong reason why a firewall would drop a SYN because ports were used
> in a previous session ?

We don't know why the firewall (Cisco FWSM) is dropping the packets, may be a 
bug, limitation or miss-configuration. We are trying to track this down with 
the firewall vendor.

> Previous mode can be restored by application itself, using a bind() before
> connect(), if this application knows it has a very high rate of connections
> from a particular host to a particular host. (source ports range being
> small anyway, so your firewall could complain again)

Do you mean bind() with port != 0 ? Because I am already using bind() before 
connect().

Thanks,
tavi

