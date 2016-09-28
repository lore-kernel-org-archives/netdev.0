From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 1/5] ISDN-Gigaset: Use kmalloc_array() in two functions
Date: Wed, 28 Sep 2016 18:38:10 +0200
Message-ID: <1a101dea-006f-f507-54e5-5d05ccd996ec@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <4fb300f1-ff02-7983-464f-fcbca5919dac@users.sourceforge.net>
 <1475062635.16606.27.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1475062635.16606.27.camel@tiscali.nl>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> * Multiplications for the size determination of memory allocations
>>   indicated that array data structures should be processed.
>>   Thus use the corresponding function "kmalloc_array".
> 
> Was the current code incorrect?

I suggest to use a safer interface for array allocations.


> What makes kmalloc_array() better?

1. How do you think about the safety checks that this function provides?

2. Will you be also affected by further software evolution here?
   2016-07-26
   mm: faster kmalloc_array(), kcalloc()
   https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=91c6a05f72a996bee5133e76374ab3ad7d3b9b72


> I'm not going to change code just because some checker suggests to do so.

The script "checkpatch.pl" can point information out like the following.

WARNING: Prefer kmalloc_array over kmalloc with multiply


>>   This issue was detected by using the Coccinelle software.
> 
> So? And which coccinelle script was actually used?

How do you think about to look into related information sources?
https://github.com/coccinelle/coccinelle/issues/81

Would you like to experiment any further with an excerpt?


@replacement1@
expression count, target;
type T;
@@
 target =
-         kmalloc(sizeof(T) * (count)
+         kmalloc_array(count, sizeof(T)
                        , ...);

@replacement2@
expression count, pointer, target;
@@
 target =
-         kmalloc(sizeof(*pointer) * (count)
+         kmalloc_array(count, sizeof(*pointer)
                        , ...);


> I couldn't spot a coccinelle script doing that in the current tree.

This is true for such a software update opportunity.


>> * Replace the specification of a data structure by a pointer dereference
>>   to make the corresponding size determination a bit safer according to
>>   the Linux coding style convention.
> 
> I'm not happy with you mixing this with the above, less trivial, change.

I find that it is a useful combination. - A parameter is adjusted together
with a special function name.


>> -	drv->cs = kmalloc(minors * sizeof *drv->cs, GFP_KERNEL);
>> +	drv->cs = kmalloc_array(minors, sizeof(*drv->cs), GFP_KERNEL);
> 
> For "minors" the same holds as for "channels", above.
> 
> And you snuck in a parentheses change. That should have probably been
> merged with 5/5.

Would you prefer to add them in another update step?

Regards,
Markus
