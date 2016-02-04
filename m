From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ethernet: davicom: fix devicetree irq resource
Date: Thu, 4 Feb 2016 23:56:38 +0300
Message-ID: <56B3BB06.9010506@cogentembedded.com>
References: <1454535609-7290-1-git-send-email-robert.jarzmik@free.fr>
 <56B38767.6040005@cogentembedded.com> <87d1sc5hsh.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:34151 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcBDU4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 15:56:42 -0500
Received: by mail-lb0-f181.google.com with SMTP id cw1so38593784lbb.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 12:56:41 -0800 (PST)
In-Reply-To: <87d1sc5hsh.fsf@belgarion.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2016 11:42 PM, Robert Jarzmik wrote:

>>     Your patch summary prefixes are too verbose, it was enough to say only
>> "dm9000: ".

    Or "davicom: dm9000: ". Missing the driver name itself doesn't look very 
consistent. :-)

> Well, I don't agree here. The subsystem should be fully specified, at least this
> is something I require in pxa, something that is also required in sound/*, etc
> ... If David doesn't object, I'll keep it that way. As it's his tree, his
> decision in the end, so let's have him decide.

    I expect that he disagrees with you. Let's wait...

>>> -	/* If there is no IRQ type specified, default to something that
>>> -	 * may work, and tell the user that this is a problem */
>>> -
>>> -	if (irqflags == IRQF_TRIGGER_NONE)
>>> -		irqflags = irq_get_trigger_type(dev->irq);
>>> -
>>> -	if (irqflags == IRQF_TRIGGER_NONE)
>>> +	/* If there is no IRQ type specified, tell the user that this is a
>>> +	 * problem */
>>
>>     The networking code formats comments this way:
>>
>> /* foo
>>   * bar
>>   */
> May I know where this is documented ?

    Documentation/CodingStyle, chapter 8. Have you run your patch thru 
scripts/checkpatch.pl?

> I'm asking because I didn't find it, because I parsed drivers/net/*.c files, and
> the standard kernel comment style was there, ie:
> /*
>   * foo
>   * bar
>   */

    But you didn't follow it as well?

> I was reusing the previous comment style,

    Ah...

> but I will change it for the standard
> kernel style if you wish.

    Yes, I think checkpatch.pl checks for that, --strict is forced for the 
networking code.


>>> +	ndev->irq = platform_get_irq(pdev, 0);
>>> +	if (ndev->irq <= 0) {
>>
>>     I don't recommend checking for 0 and returning early in this case --
>> you'll signal a probe success this way. Either ignore 0 or return -E<smth>
>> in this case. Unfortunately, platform_get_irq() is so sloppily coded now that it
>> *can* return 0 on error. :-(

    I'll try looking into this issue once I get more free time...

> Ah we had that discussion not very long ago, didn't we ? :)

    Yeah, I remembered that just after hitting <Send>. :-)

> And I think I'll reuse the "if (ndev->irq < 0) {" solution to be consistent with
> myself.

> Thanks for the review.

    My pleasure. :-)

MBR, Sergei
