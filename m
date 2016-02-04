From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: ethernet: davicom: fix devicetree irq resource
Date: Thu, 04 Feb 2016 21:42:22 +0100
Message-ID: <87d1sc5hsh.fsf@belgarion.home>
References: <1454535609-7290-1-git-send-email-robert.jarzmik@free.fr>
	<56B38767.6040005@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B38767.6040005@cogentembedded.com> (Sergei Shtylyov's message
	of "Thu, 4 Feb 2016 20:16:23 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

> Hello.
>
>    Your patch summary prefixes are too verbose, it was enough to say only
> "dm9000: ".
Well, I don't agree here. The subsystem should be fully specified, at least this
is something I require in pxa, something that is also required in sound/*, etc
... If David doesn't object, I'll keep it that way. As it's his tree, his
decision in the end, so let's have him decide.

>> -	/* If there is no IRQ type specified, default to something that
>> -	 * may work, and tell the user that this is a problem */
>> -
>> -	if (irqflags == IRQF_TRIGGER_NONE)
>> -		irqflags = irq_get_trigger_type(dev->irq);
>> -
>> -	if (irqflags == IRQF_TRIGGER_NONE)
>> +	/* If there is no IRQ type specified, tell the user that this is a
>> +	 * problem */
>
>    The networking code formats comments this way:
>
> /* foo
>  * bar
>  */
May I know where this is documented ?
I'm asking because I didn't find it, because I parsed drivers/net/*.c files, and
the standard kernel comment style was there, ie:
/*
 * foo
 * bar
 */

I was reusing the previous comment style, but I will change it for the standard
kernel style if you wish.

>>
>> +	ndev->irq = platform_get_irq(pdev, 0);
>> +	if (ndev->irq <= 0) {
>
>    I don't recommend checking for 0 and returning early in this case -- 
> you'll signal a probe success this way. Either ignore 0 or return -E<smth>
> in this case. Unfortunately, platform_get_irq() is so sloppily coded now that it
> *can* return 0 on error. :-(
Ah we had that discussion not very long ago, didn't we ? :)
And I think I'll reuse the "if (ndev->irq < 0) {" solution to be consistent with
myself.

Thanks for the review.

-- 
Robert
