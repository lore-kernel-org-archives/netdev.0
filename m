From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delay scheduler
Date: Fri, 18 Jun 2004 07:40:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E01767AF6@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David Greaves" <david@dgreaves.com>, "Jens Laas" <jens.laas@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jens/David:

Did not mean to get off the list. For some reason, my subscription to
netdev is not working (even after re-subscribing). So, I grabbed your
message off of the archive.

I am trying to recreate your failure scenario in our lab. In the
meantime, please send me any new information you have on this issue.

Thanks,
ganesh 
 
-------------------------------------------------
Ganesh Venkatesan
Network/Storage Division, Hillsboro, OR

-----Original Message-----
From: David Greaves [mailto:david@dgreaves.com] 
Sent: Friday, June 18, 2004 5:52 AM
To: Jens Laas
Cc: Stephen Hemminger; netdev@oss.sgi.com; Venkatesan, Ganesh
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+
delay scheduler

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
>> From hereon down it's 2.6.7 with Stephen's recent delay scheduler
patch
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
I expected it to take longer to run out of buffers - that didn't happen
:)

(Anyway, on retesting I find that this was wrong - I suspect the 
interface was down and I didn't notice)

>
> I had hoped to hear something about this from Scott..

I'm happy to hear from anyone - I don't have *that* long until my RMA 
option expires and I don't fancy keeping them as ornaments!

David
