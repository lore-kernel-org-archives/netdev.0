From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Fri, 20 Mar 2009 13:20:47 +0800
Message-ID: <b6a2187b0903192220p67880251ue8ba9b392f11da01@mail.gmail.com>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local>
	 <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f208.google.com ([209.85.217.208]:33477 "EHLO
	mail-gx0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbZCTFUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 01:20:50 -0400
In-Reply-To: <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 12:55 PM, Jeff Chua <jeff.chua.linux@gmail.com> wrote:
> On Thu, Mar 19, 2009 at 5:38 PM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
>> On Thu, 2009-03-19 at 12:49 +0800, Jeff Chua wrote:
>>
>>> Ignore the above loop thing. The cause seems to be this one instead.
>>>
>>>
>>> # this needs patch to work ...
>>> iwconfig wlan0 mode Managed
>>> ifconfig wlan0 up
>>> iwconfig wlan0 essid xxx
>>> iwconfig wlan0 key restricted xxx
>>> iwconfig wlan0 ap auto channel auto
>>
>> If you swap the key and essid lines, it will probably always work. But
>> I've yet to analyse your data to see why it doesn't in the other case.
>
> Doesn't. Taking away "hiwconfig wlan0 ap auto channel auto" makes it works.

More discoveries...

It seems position of "ifconfig wlan0 up" matters

1) It can't be before iwconfig which will result in "SET failed on
device wlan0 ; Device or resource busy".

2) _Before_ "essid" and "key" settings. "ap auto channel auto" MUST NOT BE SET.

3) _After_ "essid" and "key". Ensure all iwconfig settings comes
before "ifconfig".


So, it seems "ifconfig" must be done as the last stage.

Thanks,
Jeff.
