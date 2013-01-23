From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 17:08:13 -0800
Message-ID: <1358903293.12374.492.camel@edumazet-glaptop>
References: <1358892924.12374.157.camel@edumazet-glaptop>
	 <CAEP_g=_AebncQ6_tHDA0rN=ya4tAqpN2i8FuQ1hqa8mOgj_AJA@mail.gmail.com>
	 <1358894653.12374.201.camel@edumazet-glaptop>
	 <20130122.194143.1205292712415183747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:53309 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab3AWBIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 20:08:16 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so4418741pad.17
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 17:08:15 -0800 (PST)
In-Reply-To: <20130122.194143.1205292712415183747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 19:41 -0500, David Miller wrote:

> We don't emit crap onto the wire knowingly.  Jesse is right.
> 
> If you want to do software GSO in situations where we know that the
> paged data cannot be modified asynchronously, you'll have to
> explicitly support that.
> 
> I will not accept us saying that allowing the emission of bad
> checksums is OK.  It never is.  That's terrible behavior, and creates
> impossible to disagnose problems.

How is this related to GRE only ?

We have dozen of skb_checksum_help() calls that basically have the same
issue.

Am I missing some obvious thing ?
