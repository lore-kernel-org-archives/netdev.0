From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sun, 23 Aug 2009 19:54:48 +0200
Message-ID: <20090823175448.GA4111@ami.dom.local>
References: <4A0C7443.1010000@googlemail.com> <1243042174.3580.23.camel@obelisk.thedillows.org> <m1skfkrik2.fsf@fess.ebiederm.org> <1250895567.23419.1.camel@obelisk.thedillows.org> <1250897657.23419.5.camel@obelisk.thedillows.org> <m1iqggf4rf.fsf@fess.ebiederm.org> <m18whcf3w2.fsf@fess.ebiederm.org> <1250973787.3582.14.camel@obelisk.thedillows.org> <4A91799D.7090802@gmail.com> <4A917FD8.6030201@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?iso-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934077AbZHWRzQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A917FD8.6030201@ziu.info>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 23, 2009 at 07:43:52PM +0200, Michal Soltys wrote:
> Jarek Poplawski wrote:
>> David Dillow wrote, On 08/22/2009 10:43 PM:
>>
>>> On Sat, 2009-08-22 at 05:07 -0700, Eric W. Biederman wrote:
>>>> ebiederm@xmission.com (Eric W. Biederman) writes:
>>>>
>>>>> David Dillow <dave@thedillows.org> writes:
>>>>>
>>>>>> Re-looking at the code, I'd guess that some IRQ status line is getting
>>>>>> stuck high, but I don't see why -- we should acknowledge all outstanding
>>>>>> interrupts each time through the loop, whether we care about them or
>>>>>> not.
>>>>>>
>>>>>> Could reproduce a problem with the following patch applied, and send the
>>>>>> full dmesg, please?
>>>>> Here is what I get.
>>>>>
>>>>> r8169 screaming irq status 00000085 mask 0000ffff event 0000803f napi 0000001d
>>>> And now that the machine has come out of it, that was followed by:
>>>> Looks like the soft lockup did not manage to trigger in this case.
>>>
>>> I need some more context, please. What is the network load through this
>>> NIC when you have the issues? Light, heavy? Can you give me more details
>>> about the machine? A full dmesg from boot until this happens would help
>>> quite a bit. At a minimum it would help answer which version of the chip
>>> we're dealing with and what the machine it is in looks like.
>>>
>>> Can you reproduce this with pci=nomsi? I'm assuming it the chip running
>>> in MSI mode.
>>>
>>> Also, can you reproduce it when booting UP (or maxcpus=1)? I'm thinking
>>> about a race between rtl8169_interrupt() and rtl8169_poll(), but it
>>> isn't jumping out at me.
>>>
>>> Also, I'm having connectivity troubles this weekend, so my response may
>>> be spotty. :(
>>>
>>
>>
>> BTW, FYI, it seems Michal stopped tracking this problem, but he
>> found this commit problematic as well.
>>
>> From: Michal Soltys <soltys@ziu.info>
>> Subject: Re: r8169 (+others ?) and note_interrupt performance hit on 2.6.30.x
>> Date: Wed, 05 Aug 2009 20:54:47 +0200
>> http://marc.info/?l=linux-netdev&m=124949848110710&w=2
>>
>
> Well - not really stopped, but not sure what to look at before that  
> particular commit (as cpu load for the tests I've done increased rather  
> significantly as well before that, and after 2.6.29 - but it doesn't  
> seem to be related to the driver). And I was away for over a week...
>
> As fot the changes that commit introduced, here's is link to the mail  
> with the oprofile I did back then:
>
> http://www.spinics.net/lists/netdev/msg102709.html
>
> I'm happy to assist any way I can.

Very nice :-) I guess David might be interested in your dmesg etc.
(as above) too.

Jarek P.
