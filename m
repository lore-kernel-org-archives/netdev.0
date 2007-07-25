From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 08:01:14 -0400
Message-ID: <1185364874.26013.192.camel@localhost>
References: <20070725.013154.34764933.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:19899 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbXGYMBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 08:01:20 -0400
Received: by wx-out-0506.google.com with SMTP id h31so153905wxd
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 05:01:18 -0700 (PDT)
In-Reply-To: <20070725.013154.34764933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-25-07 at 01:31 -0700, David Miller wrote:
> We're getting there, slowly...
> 
> 1) netif_napi_init() is added, the workqueue/requeue stuff
>    as discussed is not needed so you won't see that here
..
....
> Another thing that's really apparent now is all the wacky
> napi->weight values various drivers use.  Just grep for
> netif_napi_init() in the patch or a patched tree to see what
> I mean.  So much of it doesn't make any sense and I'm tempted
> to just remove the argument and make everyone use 32 or 64
> or something like that :-)  Or, default to some value across
> the board, and let drivers override that on a case by case
> basis with a BIG FAT COMMENT above the override describing
> why the different value is being used and precisely what
> tests were performed to validate that different value.

Sounds reasonable.
32-64 for Gige seemed to work well as i recall. 10/100 was around 16.
But that shouldnt matter i think: because the poll from the core is
based on Varghese's DRR, it probably will be fine if you just gave all
the same value and the "deficit" part will kick in when needed. Some
testing maybe required but theoretically i dont see a problem. 
 
BTW: The current kernel code has a "bug" - where if a driver
forgot to set its weight it would be indeterminate, so even for this
reason it will be a good idea to enforce a default.

Sorry, havent been following the thread - thanks for CCing me, will try
to catch up at some point.

cheers,
jamal



