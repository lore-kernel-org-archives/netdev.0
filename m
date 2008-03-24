From: Andi Kleen <andi@firstfloor.org>
Subject: Re: O(n^2) or worse ?   cat /proc/net/tcp
Date: 24 Mar 2008 05:06:28 +0100
Message-ID: <87lk487ol7.fsf@basil.nowhere.org>
References: <20080323224307.GL3700@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:24349 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbYCXEGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 00:06:31 -0400
In-Reply-To: <20080323224307.GL3700@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Aarnio <matti.aarnio@zmailer.org> writes:
> 
> I did observe odd slowness at first with  "lsof -p .."  program, 

You could oprofile it.

> then at
> "netstat -na".  Same slowdown happens with:  cat /proc/net/tcp
> (that 'cat' took 25 seconds...)

/proc/net/tcp should be only O(n^2) if the application does a lot of 
open()/seek()/read()/close() for very small chunks, but at least netstat
doesn't do that. Not sure about lsof though.

-Andi
