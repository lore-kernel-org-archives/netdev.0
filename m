From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delay
 scheduler
Date: Fri, 18 Jun 2004 13:51:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D2E563.7080302@dgreaves.com>
References: <40CDD68C.8070509@dgreaves.com> <20040615155111.26d6b809@dell_ss3.pdx.osdl.net> <40D0280B.2030308@dgreaves.com> <Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se> <40D2B114.5020201@dgreaves.com> <Pine.LNX.4.60.0406181217060.1089@jlaas2.data.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jens Laas <jens.laas@data.slu.se>
In-Reply-To: <Pine.LNX.4.60.0406181217060.1089@jlaas2.data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

New info:
I booted into XP and the card works there - so it doesn't look like a 
simple hardware incompatibility.
[I've got no real way to test the performance but cygwin's wget against 
apache1.3 on the linux box returns about 25M/s initially and then 15M/s 
sustained for 500Mb]

Jens Laas wrote:

>>
>> I'm speaking with Ganesh Venkatesan at intel about it. Ganesh you 
>> went off list - do you want to include Jens or maybe go back on-list?
>
>
> If others run into this problem I'm sure they'll appreciate if its on 
> list.
> Since we have no idea what causes this (AFAIK) it may be a more 
> general problem than the device driver.

I tend to agree - but I wasn't sure if this was the place and I'll do as 
I'm told ;)

>> A simple failure case for me is : 'ping -s 1500 '
>> This doesn't cause the timout but doesn't succeed either.
>>
>> ping -f with standard packet size succeeds (slow rate though) and 
>> doesn't timeout.
>
>
>
> I dont see the ping problems at all. Unless you try to ping when the 
> interface has "hanged" ?

<sigh> thought that might be helpful.
Ping with -s and -f seems to allow me to trigger errors and it seems a 
lot more debug-able than scp or nfs :)
No all tests are when it's reset and 'clean'

>> ============
>> From hereon down it's 2.6.7 with Stephen's recent delay scheduler patch
>>
>> This changed the behaviour.
>
>
>
> This is strange unless you are actually using the delay scheduler ?
> Default is sch_generic (that is pfifo) that does not exhibit the 
> problems correct by the patch.

I'll go back and double check in case I cocked up...
(I noticed the e1000 module rebuild but you're right that's incidental)

I've rebuilt the kernel and modules with and w/o patch and rebooted a 
few times and I can't reproduce that effect - sorry for the red herring.
So after I reverted Stephens patch the results I reported are still 
reproducable w/o the patch.

>> 10592 packets transmitted, 10591 packets received, 0% packet loss
>> round-trip min/avg/max = 5.4/5.5/83.5 ms
>>
>> Increasing Transmit Descriptors to 4096 avoids the No buffer space 
>> available with packet sizes up to -s65468 (still 100% failure though)
>
>
> Increasing nr of buffers is not a way to fix the problem.

agreed - however in my ignorance of the deep behaviour I'm reporting 
things that affect behaviour in ways I don't expect.
I expected it to take longer to run out of buffers - that didn't happen :)

(Anyway, on retesting I find that this was wrong - I suspect the 
interface was down and I didn't notice)

>
> I had hoped to hear something about this from Scott..

I'm happy to hear from anyone - I don't have *that* long until my RMA 
option expires and I don't fancy keeping them as ornaments!

David
