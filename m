From: Michal Soltys <soltys@ziu.info>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sun, 23 Aug 2009 19:43:52 +0200
Message-ID: <4A917FD8.6030201@ziu.info>
References: <200903041828.49972.m.bueker@berlin.de>	 <1242001754.4093.12.camel@obelisk.thedillows.org>	 <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>	 <1242077392.3716.15.camel@lap75545.ornl.gov>	 <4A09DC3E.2080807@googlemail.com>	 <1242268709.4979.7.camel@obelisk.thedillows.org>	 <4A0C6504.8000704@googlemail.com>	 <1242328457.32579.12.camel@lap75545.ornl.gov>	 <4A0C7443.1010000@googlemail.com>	 <1243042174.3580.23.camel@obelisk.thedillows.org>	 <m1skfkrik2.fsf@fess.ebiederm.org>	 <1250895567.23419.1.camel@obelisk.thedillows.org>	 <1250897657.23419.5.camel@obelisk.thedillows.org>	 <m1iqggf4rf.fsf@fess.ebiederm.org>  <m18whcf3w2.fsf@fess.ebiederm.org> <1250973787.3582.14.camel@obelisk.thedillows.org> <4A91799D.7090802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934052AbZHWRnz@vger.kernel.org>
In-Reply-To: <4A91799D.7090802@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> David Dillow wrote, On 08/22/2009 10:43 PM:
> 
>> On Sat, 2009-08-22 at 05:07 -0700, Eric W. Biederman wrote:
>>> ebiederm@xmission.com (Eric W. Biederman) writes:
>>>
>>>> David Dillow <dave@thedillows.org> writes:
>>>>
>>>>> Re-looking at the code, I'd guess that some IRQ status line is getting
>>>>> stuck high, but I don't see why -- we should acknowledge all outstanding
>>>>> interrupts each time through the loop, whether we care about them or
>>>>> not.
>>>>>
>>>>> Could reproduce a problem with the following patch applied, and send the
>>>>> full dmesg, please?
>>>> Here is what I get.
>>>>
>>>> r8169 screaming irq status 00000085 mask 0000ffff event 0000803f napi 0000001d
>>> And now that the machine has come out of it, that was followed by:
>>> Looks like the soft lockup did not manage to trigger in this case.
>> 
>> I need some more context, please. What is the network load through this
>> NIC when you have the issues? Light, heavy? Can you give me more details
>> about the machine? A full dmesg from boot until this happens would help
>> quite a bit. At a minimum it would help answer which version of the chip
>> we're dealing with and what the machine it is in looks like.
>> 
>> Can you reproduce this with pci=nomsi? I'm assuming it the chip running
>> in MSI mode.
>> 
>> Also, can you reproduce it when booting UP (or maxcpus=1)? I'm thinking
>> about a race between rtl8169_interrupt() and rtl8169_poll(), but it
>> isn't jumping out at me.
>> 
>> Also, I'm having connectivity troubles this weekend, so my response may
>> be spotty. :(
>> 
> 
> 
> BTW, FYI, it seems Michal stopped tracking this problem, but he
> found this commit problematic as well.
> 
> From: Michal Soltys <soltys@ziu.info>
> Subject: Re: r8169 (+others ?) and note_interrupt performance hit on 2.6.30.x
> Date: Wed, 05 Aug 2009 20:54:47 +0200
> http://marc.info/?l=linux-netdev&m=124949848110710&w=2
> 

Well - not really stopped, but not sure what to look at before that 
particular commit (as cpu load for the tests I've done increased rather 
significantly as well before that, and after 2.6.29 - but it doesn't 
seem to be related to the driver). And I was away for over a week...

As fot the changes that commit introduced, here's is link to the mail 
with the oprofile I did back then:

http://www.spinics.net/lists/netdev/msg102709.html

I'm happy to assist any way I can.
