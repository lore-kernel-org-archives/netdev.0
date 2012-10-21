From: Daniel Mack <zonque@gmail.com>
Subject: Re: was: Re: A reliable kernel panic (3.6.2) and system crash when
 visiting a particular website
Date: Sun, 21 Oct 2012 17:22:19 +0200
Message-ID: <5084132B.8080609@gmail.com>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05> <20121020162759.GA12551@liondog.tnic> <966148591.30347.1350754909449.JavaMail.mail@webmail08> <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic> <1781795634.31179.1350774917965.JavaMail.mail@webmail04> <20121021002424.GA16247@liondog.tnic> <1798605268.19162.1350784641831.JavaMail.mail@webmail17> <20121021110851.GA6504@liondog.tnic> <121566322.100103.1350820776893.JavaMail.mail@webmail20> <5083E4AA.3060807@gmail.com> <317435358.100327.1350822615555.JavaMail.mail@webmail20> <508404F5.2010502@gmail.com> <901486978.101922.1350831476734.JavaMail.mail@webmail20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bp@alien8.de, pavel@ucw.cz, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org,
	linux-media@vger.kernel.org, linux-usb@vger.kernel.org,
	alsa-devel@alsa-project.org
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <901486978.101922.1350831476734.JavaMail.mail@webmail20>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.10.2012 16:57, Artem S. Tashkinov wrote:
>> On Oct 21, 2012, Daniel Mack  wrote: 
>>
>> [Cc: alsa-devel]
>>
>> On 21.10.2012 14:30, Artem S. Tashkinov wrote:
>>> On Oct 21, 2012, Daniel Mack wrote: 
>>>
>>>> A hint at least. How did you enable the audio record exactly? Can you
>>>> reproduce this with arecord?
>>>>
>>>> What chipset are you on? Please provide both "lspci -v" and "lsusb -v"
>>>> dumps. As I said, I fail to reproduce that issue on any of my machines.
>>>
>>> All other applications can read from the USB audio without problems, it's
>>> just something in the way Adobe Flash polls my audio input which causes
>>> a crash.
>>>
>>> Just video capture (without audio) works just fine in Adobe Flash.
>>
>> Ok, so that pretty much rules out the host controller. I just wonder why
>> I still don't see it here, and I haven't heard of any such problem from
>> anyone else.
>>
>> Some more questions:
>>
>> - Which version of Flash are you running?
> 
> Google Chrome has its own version of Adobe Flash:
> 
> Name:	Shockwave Flash
> Description:	Shockwave Flash 11.4 r31
> Version:	11.4.31.110

So that's the same that I'm using.

>> - Does this also happen with Firefox?
> 
> No, Adobe Flash in Firefox is an older version (Shockwave Flash 11.1 r102), it shows
> just two input devices instead of three which the newer Flash players sees.
> 
> * HDA Intel PCH
> * USB Device 0x46d:0x81d

And that works, I assume? Does the second choice in the newer Flash
version work maybe?

>> - Does flash access the device directly or via PulseAudio?
> 
> PA is not installed on my computer, so Flash accesses it directly via ALSA calls.

Ok, Same here.

>> - Could you please apply the attached patch and see what it spits out to
>> dmesg once Flash opens the device? It returns -EINVAL in the hw_params
>> callback to prevent the actual streaming. On my machine with Flash
>> 11.4.31.110, I get values of 2/44800/1/32768/2048/0, which seems sane.
>> Or does your machine still crash before anything is written to the logs?
> 
> I will try it a bit later.

Yes, we need to trace the call chain and see at which point the trouble
starts. What could help is tracing the google-chrome binary with strace
maybe. At least we would see the ioctl command sequence, if the log file
survives the crash.

As the usb list is still in Cc: - Artem's lcpci dump shows that his
machine features XHCI controllers. Can anyone think of a relation to
this problem?

And Artem, is there any way you boot your system on an older machine
that only has EHCI ports? Thinking about it, I wonder whether the freeze
in VBox and the crashes on native hardware have the same root cause. In
that case, would it be possible to share that VBox image?


Daniel
