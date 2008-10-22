From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: IP-less bridge as a martian source
Date: Wed, 22 Oct 2008 17:00:43 +0200
Message-ID: <87wsg0wu78.fsf@tac.ki.iif.hu>
References: <87tzb6nodj.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:50443 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbYJVPAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 11:00:45 -0400
Received: from wferi by tac.ki.iif.hu with local (Exim 4.63)
	(envelope-from <wferi@niif.hu>)
	id 1KsfCV-0007rz-0j
	for netdev@vger.kernel.org; Wed, 22 Oct 2008 17:00:43 +0200
In-Reply-To: <87tzb6nodj.fsf@tac.ki.iif.hu> (Ferenc Wagner's message of "Tue,
	21 Oct 2008 14:06:48 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ferenc Wagner <wferi@niif.hu> writes:

> I expected an IP-less bridge interface to pick up no IP packets, but
> apparently this isn't the case: broadcast packets with destination
> address 255.255.255.255 are reported as martians by the 2.6.18
> kernel, which I find counterintuitive (I know 2.6.18 is rather old,
> but that's the one supported by Xen).
>
>   1. Is this the expected behaviour?
>
>   2. I tried to cut down the logs by explicit iptables drops, but
>      didn't succeed.  Does martian detection happen before the
>      netfilter rules?  (I know I can disable martian logging by
>      interface, but wanted finer granularity.)
>
> If somebody could also enlighten me on the following [...]

That packet doubling turned out to be a bonding configuration error:
it was in round-robin mode instead of active-backup (part of joys of
ditstro upgrade).  Also I found a way to probe the above question
under 2.6.26, but I'd still be interested in the expected behaviour.
-- 
Thanks,
Feri.
