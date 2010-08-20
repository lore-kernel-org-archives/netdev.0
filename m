From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 09:12:10 +0300
Message-ID: <4C6E1CBA.2060605@fs.uni-ruse.bg>
References: <bug-16626-10286@https.bugzilla.kernel.org/>	<20100819152143.8a57c465.akpm@linux-foundation.org>	<4C6E0C99.2060407@fs.uni-ruse.bg> <20100819221142.b8f6a70a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:60790 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751167Ab0HTGMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 02:12:13 -0400
In-Reply-To: <20100819221142.b8f6a70a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 20.8.2010 =D0=B3. 08:11, Andrew Morton =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> On Fri, 20 Aug 2010 08:03:21 +0300 Plamen Petrov<pvp-lsts@fs.uni-ruse=
=2Ebg>  wrote:
>
>> (responding via emailed reply-to-all)
>>
>> ____ 20.8.2010 __. 01:21, Andrew Morton ____________:
>>>
>>> (switched to email.  Please respond via emailed reply-to-all, not v=
ia the
>>> bugzilla web interface).
>>>
>>> On Thu, 19 Aug 2010 09:57:25 GMT
>>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>>
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D16626
>>>>
>>>>              Summary: Machine hangs with EIP at skb_copy_and_csum_=
dev
>>>>              Product: Drivers
>>>>              Version: 2.5
>>>>       Kernel Version: 2.6.36-rc1-00127-g763008c
>>>>             Platform: All
>>>>           OS/Version: Linux
>>>>                 Tree: Mainline
>>>>               Status: NEW
>>>>             Severity: blocking
>>>>             Priority: P1
>>>>            Component: PCI
>>>>           AssignedTo: drivers_pci@kernel-bugs.osdl.org
>>>>           ReportedBy: pvp-lsts@fs.uni-ruse.bg
>>>>           Regression: Yes
>>>
>>> A post-2.6.35 regression.
>>>
>>>>
>>>> After upgrade from 2.6.33.7 to 2.6.35.2 a server hanged twice, so
>>>> continued on 2.6.33.7.
>>>>
>>>> Today decided to try lates Linus' tree with no luck.
>>>>
>>>> The first time I started on 2.6.36-rc1-00127-g763008c it ran for a=
 few
>>>> minutes, then whent dead with this on the screen:
>>>> [picture 1]
>>>> http://picpaste.com/9cfb03116d41f27568e1bb2a67b7f4dc.jpg
>>>>
>>>> [picture 2]
>>>> Then I power-cycled the machine, only two get this:
>>>> http://picpaste.com/6d70f453e462d1aed038781ad4bdb741.jpg
>>>>
>>>> And because [picture 2] seemed too bad on the lower half of the sc=
reen,
>>>> here is
>>>> [picture 3]
>>>> http://picpaste.com/0a51ae079ace2e4abd9e9d29226069f7.jpg
>>>
>>> Might have triggered the BUG_ON() in skb_copy_and_csum_dev().  Migh=
t be
>>> a tg3 thing.  Hard to tell.
>>>
>>> It'd be really nice to get that first screenful.  Sigh.  How long h=
ave
>>> we had this oops-scrolls-off problem??  Perhaps you could set
>>> /proc/sys/kernel/printk_delay to 100 (it's in milliseconds) so that=
 the
>>> oops scrolls past nice and slowly?
>>>
>> So you need the begining of the oops screen - I will try to get that
>> with the proposed pirntk_delay setting.
>
> Thanks.
>
>> But wich kernel should I use? Linus' latest tree or 2.6.35.2 ? They
>> both fail the same way here, as far as I can say.
>
> Current mainline would be best, because we'd fix the bug there first
> then backport the fix into -stable.  But it doesn't matter a lot in
> this case - whatever's most convenient for you, I'd say.
>
With the "echo 100 > /proc/sys/kernel/printk_delay" command run by
/etc/rc.d/rc.local, while still on 2.6.36-rc1-00127-g763008c, I got
these:

[picture 4]
http://picpaste.com/aa3e373e894179e8ba19587ed63d8104.jpg

[picture 5]
http://picpaste.com/9bc4bdc04f5a84fdaf49d6e1db23ede8.jpg

[picture 6]
http://picpaste.com/da3ccd69a0a1221bb55f48b39c4ad950.jpg

Hope the above help.

And by the way, I think you are correct that this is a
post-2.6.35 thing, because 2.6.35.2 was the first to give
me this kind of problems, and I can confirm that 2.6.34
does not have it, because the system was on 2.6.34.4 for
the last 12 hours without problems, then just a moment ago
crashed on 2.6.36-rc1-00127-g763008c, and now back on
2.6.34.4

P.S. Shouldn't "echo 100 > /proc/sys/kernel/printk_delay" be
somewhere on the "How to debug a crashing kernel guide"
somewhere?

Thanks!
