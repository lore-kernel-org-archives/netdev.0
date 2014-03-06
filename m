From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: Re: Bug 71591 - Temporary address re-generated when it should not
 (public address about to expire)
Date: Thu, 06 Mar 2014 18:02:16 +0100
Message-ID: <5318AA18.6040705@web.de>
References: <5318A47D.2020204@web.de> <20140306164309.GB3092@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:61688 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848AbaCFRCW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 12:02:22 -0500
Received: from [192.168.178.101] ([84.153.198.61]) by smtp.web.de (mrweb102)
 with ESMTPSA (Nemesis) id 0LyUgM-1XIN0l0oHG-015rwL for
 <netdev@vger.kernel.org>; Thu, 06 Mar 2014 18:02:21 +0100
In-Reply-To: <20140306164309.GB3092@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the hint on the correct procedure. Next try ..
Output from checkpatch.p --strict
total: 0 errors, 0 warnings, 0 checks, 10 lines checked
patch-3.10.32-ipv6_create_tempaddr has no obvious style problems and is 
ready for submission.

diff -upNr linux-3.10.32.vanilla/net/ipv6/addrconf.c 
linux-3.10.32.patched/net/ipv6/addrconf.c
--- linux-3.10.32.vanilla/net/ipv6/addrconf.c    2014-02-22 
14:41:54.000000000 -0600
+++ linux-3.10.32.patched/net/ipv6/addrconf.c    2014-03-06 
17:07:12.953699438 -0600
@@ -1111,8 +1111,9 @@ retry:
       * Lifetime is greater than REGEN_ADVANCE time units.  In particular,
       * an implementation must not create a temporary address with a zero
       * Preferred Lifetime.
+     * Note that tmp_prefered_lft is relative to ifp->tstamp not now.
       */
-    if (tmp_prefered_lft <= regen_advance) {
+    if (tmp_prefered_lft <= regen_advance + age) {
          in6_ifa_put(ifp);
          in6_dev_put(idev);
          ret = -1;
Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>

Rgds,
Heiner


Am 06.03.2014 17:43, schrieb Hannes Frederic Sowa:
> On Thu, Mar 06, 2014 at 05:38:21PM +0100, Heiner Kallweit wrote:
>> Recently I faced the issue that a public address was about to expire and
>> 3s before expiry a new temporary address was generated which instantly
>> went into deprecated state.
>> This didn't do any harm however it's wrong IMHO. Problem seems to be in
>> function ipv6_create_tempaddr in addrconf.c.
>> A new temporary address is generated if this condition is met:
>> tmp_prefered_lft > regen_advance
>> tmp_prefered_lft however is an offset from tstamp, not from now.
>> This condition only checks that the new address is preferred until more
>> than regen_advance from tstamp,
>> but it should check that the new address is preferred until more than
>> regen_advance from now.
>>
>> I submitted this issue to kernel bugzilla -> 71591
>> Hannes asked me to propose a patch, here it comes.
> You would need to follow Documentation/SubmittingPatches and provide a proper
> signed-off-by.
>
> Basically if scripts/checkpatch.pl --strict doesn't complain on your patch any
> more, then you're ready to submit.
>
> Otherwise the patch looks good to me.
>
> Thanks,
>
>    Hannes
>
>
