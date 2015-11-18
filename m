From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 18 Nov 2015 22:20:54 +0100
Message-ID: <564CEBB6.5010608@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <1447880426.567228.443640225.76C879B7@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447880426.567228.443640225.76C879B7@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 18.11.2015 um 22:00 schrieb Hannes Frederic Sowa:
>
>
> On Wed, Nov 18, 2015, at 21:23, Stefan Priebe wrote:
>>
>> Am 17.11.2015 um 20:43 schrieb Thomas Gleixner:
>>> On Tue, 17 Nov 2015, Stefan Priebe wrote:
>>>> I've now also two gdb backtraces from two crashes:
>>>> http://pastebin.com/raw.php?i=yih5jNt8
>>>>
>>>> http://pastebin.com/raw.php?i=kGEcvH4T
>>>
>>> They don't tell me anything as I have no idea of the inner workings of
>>> asterisk. You might be better of to talk to the asterisk folks to help
>>> you track down what that thing is waiting for, so we can actually look
>>> at a well defined area.
>>
>> The asterisk guys told me it's a livelock asterisk is waiting for
>> getaddrinfo / recvmsg.
>>
>> Thread 2 (Thread 0x7fbe989c6700 (LWP 12890)):
>> #0  0x00007fbeb9eb487d in recvmsg () from /lib/x86_64-linux-gnu/libc.so.6
>> #1  0x00007fbeb9ed4fcc in ?? () from /lib/x86_64-linux-gnu/libc.so.6
>> #2  0x00007fbeb9ed544a in ?? () from /lib/x86_64-linux-gnu/libc.so.6
>> #3  0x00007fbeb9e92007 in getaddrinfo () from
>> /lib/x86_64-linux-gnu/libc.so.6
>
> Florian Weimer recently patched glibc to detect filedescriptors which
> have been reused incorrectly in the glibc name resolving routines:
> <https://sourceware.org/ml/libc-alpha/2015-10/msg00865.html>
>
> Could you determine the type of filedescriptor in /proc/pid/fd and
> /proc/net/netlink by matching inodes?

you mean just:
la /proc/$pid/fd

and

cat /proc/net/netlink

Stefan

> Thanks,
> Hannes
>
