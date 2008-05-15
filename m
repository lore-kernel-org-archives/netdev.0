From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 18:04:04 -0400
Message-ID: <482CB354.3010205@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515215517.GI1936@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43514 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790AbYEOWEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 18:04:16 -0400
In-Reply-To: <20080515215517.GI1936@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> On Thu, May 15, 2008 at 09:07:52AM -0700, Brandeburg, Jesse wrote:
>> Alan Cox wrote:
>>> Chris Peterson <cpeterso@cpeterso.com> wrote:
>>>> I know Jeff Garzik says he's not interested in an anti-entropy
>>>> pogrom for existing net drivers, but here is the patch if anyone
>>>> else is interested..? :)  
>>>>
>>>> Only 12 net drivers are affected, the last of the
>>>> theoretically-exploitable network entropy. 
>>> Looks fine to me. If Jeff doesn't want to touch them then send them
>>> direct to Andrew/Linus.
>>>
>>> A more interesting alternative might be to mark things like network
>>> drivers with a new flag say IRQF_SAMPLE_DUBIOUS so that users can be
>>> given a switch to enable/disable their use depending upon the
>>> environment. 
>> we've been hearing rumblings of big customers wanting (maybe requiring)
>> wired network drivers from Intel to  advertise this flag.  Jeff have you
>> heard of such?
>>
>> I think the argument is that a headless system (no keyboard/mouse, no
>> soundcard, probably no video) with a libata based driver and a network
>> driver without IRQF_SAMPLE_RANDOM has *no* sources of entropy.  In this
>> case the argument is very strong for at least *some* source of entropy
>> from interrupts so that randomness can get some external input.  Just
>> try rebuilding a kernel RPM over an ssh session and you'll see what I
>> mean.
>>
>> In short, I agree with Alan's IRQF_SAMPLE_DUBIOUS, and know of Linux
>> customers who also want the same.
> 
> We have two random number interfaces:
> - /dev/random
> - /dev/urandom
> 
> If a customer wants to get data from /dev/random although there's not 
> enough entropy that's not a problem we can solve (we can only try to 
> gather more real entropy if possible).
> 
> If he can live with dubious data he can simply use /dev/urandom .
> 
> If a customer wants to use /dev/random and demands to get dubious data 
> there if nothing better is available fulfilling his wish only moves 
> the security bug from his crappy application to the Linux kernel.
> 
> But what we could perhaps do with some kind of IRQF_SAMPLE_DUBIOUS would 
> be to improve the quality of the data in /dev/urandom if there's not 
> enough entropy available?
> 
> I have seen embedded systems with zero entropy, and dubious entropy 
> might there be better than no entropy at all.
> Or am I wrong on the latter?

It's also relevant to the discussion to note that input data to kernel 
devrandom is mixed, and we can control the amount of "credit" applied to 
incoming entropy.

	Jeff




