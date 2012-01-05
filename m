From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Thu, 05 Jan 2012 12:51:49 +0100
Message-ID: <4F058ED5.2000407@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
	<4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com>
	<4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com>
	<4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com>
	<4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com>
	<4EE1E26B.6090308@grandegger.com> <4EE4F76E.3000506@essax.com>
	<4EE5C824.2050704@grandegger.com> <4EE5E321.8050104@essax.com>
	<4EE5EBBF.6080007@grandegger.com> <4EF22625.5000109@essax.com>
	<4EF2FA3F.3010308@grandegger.com> <4EF32E84.1080006@essax.com>
	<4EFED857.3000701@essax.com> <4F044FDC.60303@grandegger.com>
	<4F051927.8010600@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4F051927.8010600-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 01/05/2012 04:29 AM, Wolfgang Zarre wrote:
> Hello Wolfgang,
> 
>> Hi Wolfgang,
...
>>> diff --git a/drivers/net/can/cc770/cc770_isa.c
>>> b/drivers/net/can/cc770/cc770_isa.c
>>> index 4be5fe2..48fc128 100644
>>> --- a/drivers/net/can/cc770/cc770_isa.c
>>> +++ b/drivers/net/can/cc770/cc770_isa.c
>>> @@ -148,8 +148,7 @@ static void cc770_isa_port_write_reg_indirect(const
>>> struct cc770_priv *priv,
>>>   {
>>>       unsigned long base = (unsigned long)priv->reg_base;
>>>
>>> -    outb(reg, base);
>>> -    outb(val, base + 1);
>>> +    outw( reg + ( val<<  8), base);
>>
>> That modification does fix your problem, right? The others above don't
>> help nor harm but we don't know if it's really realted to the same
>> problem. I wll dig a bit deeper.
> 
> Exactly. The others above I removed because facing the opposite, even
> missing interrupts but then just to avoid other possible side effects
> and then assuming that they might be related.

OK. My concern: Can we be sure that 16bit accesses are always supported
by the hardware? Does a spinlock_irqsave/spinlock_irqrestore around the
8bit accesses already help?

About the "HM:" fixes, I did not find any info in the svn log. Maybe
Oliver knows why they have been added.

>>
>>>   }
>>>
>>>   static int __devinit cc770_isa_probe(struct platform_device *pdev)
>>>
>>> ---------------------------------------------------------------------------------------------
>>>
>>>
>>>
>>>
>>> Please let me know if this is OK for You, maybe You can do some tests as
>>> well.
>>
>> My board does not use indirect accesses.
>>
> 
> Ah Ok, I see, but let me know if I may help with additional tests You would
> like to have beside the other mentioned tests as long as I have the
> hardware.

I will do some test anyway.

>>> Would continue then with further tests regarding error conditions,
>>> however
>>> I realised another small issue with dropped packages at reception.
>>>
>>> As soon as You read the first time from the socket and then You stop
>>> reading
>>> the packages are not counted as 'dropped' any more which is IMHO not
>>> correct
>>> because as soon as You stop reading they should be counted as dropped
>>> again.
>>
>> Will have a closer look now...
> 
> Thanks a lot.
> Also I'll inform You as soon as I can continue with some further tests
> regarding bus states and error counters and maybe also with patches in
> case I have.

No hurry... I'm first awaiting some patches to go mainline.

Wolfgang.
