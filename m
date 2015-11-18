From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 18 Nov 2015 21:23:11 +0100
Message-ID: <564CDE2F.8000201@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1511172041480.3761@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Am 17.11.2015 um 20:43 schrieb Thomas Gleixner:
> On Tue, 17 Nov 2015, Stefan Priebe wrote:
>> I've now also two gdb backtraces from two crashes:
>> http://pastebin.com/raw.php?i=yih5jNt8
>>
>> http://pastebin.com/raw.php?i=kGEcvH4T
>
> They don't tell me anything as I have no idea of the inner workings of
> asterisk. You might be better of to talk to the asterisk folks to help
> you track down what that thing is waiting for, so we can actually look
> at a well defined area.

The asterisk guys told me it's a livelock asterisk is waiting for 
getaddrinfo / recvmsg.

Thread 2 (Thread 0x7fbe989c6700 (LWP 12890)):
#0  0x00007fbeb9eb487d in recvmsg () from /lib/x86_64-linux-gnu/libc.so.6
#1  0x00007fbeb9ed4fcc in ?? () from /lib/x86_64-linux-gnu/libc.so.6
#2  0x00007fbeb9ed544a in ?? () from /lib/x86_64-linux-gnu/libc.so.6
#3  0x00007fbeb9e92007 in getaddrinfo () from 
/lib/x86_64-linux-gnu/libc.so.6
#4  0x00000000004f2e81 in ast_sockaddr_resolve 
(addrs=addrs@entry=0x7fbe989c48d8, str=<optimized out>,
     str@entry=0x7fbe989c4a80 "10.12.12.92:2052", flags=flags@entry=0, 
family=2) at netsock2.c:268
#5  0x00007fbeb095fb8b in ast_sockaddr_resolve_first_af 
(family=<optimized out>, flag=0, name=0x7fbe989c4a80 "10.12.12.92:2052",
     addr=0x7fbeb4114948) at chan_sip.c:30797
#6  ast_sockaddr_resolve_first_transport (transport=<optimized out>, 
flag=0, name=0x7fbe989c4a80 "10.12.12.92:2052",
     addr=0x7fbeb4114948) at chan_sip.c:30828
#7  set_destination (uri=<optimized out>, p=0x7fbeb4114438) at 
chan_sip.c:10602
#8  reqprep (req=req@entry=0x7fbe989c4fc0, p=p@entry=0x7fbeb4114438, 
sipmethod=sipmethod@entry=8, seqno=<optimized out>,
     seqno@entry=0, newbranch=newbranch@entry=1) at chan_sip.c:10925
---Type <return> to continue, or q <return> to quit---
#9  0x00007fbeb0969968 in transmit_request_with_auth 
(p=p@entry=0x7fbeb4114438, newbranch=1, reliable=XMIT_RELIABLE, seqno=0,
     sipmethod=8) at chan_sip.c:14296
#10 0x00007fbeb098b704 in sip_hangup (ast=<optimized out>) at 
chan_sip.c:6822
#11 0x0000000000477b55 in ast_hangup (chan=chan@entry=0x7fbeb40ef018) at 
channel.c:2887
#12 0x000000000050ce1b in __ast_pbx_run (c=c@entry=0x7fbeb40ef018, 
args=args@entry=0x0) at pbx.c:5729
#13 0x000000000050e426 in pbx_thread (data=data@entry=0x7fbeb40ef018) at 
pbx.c:5821
#14 0x0000000000548aaa in dummy_start (data=<optimized out>) at utils.c:1151
#15 0x00007fbeb965eb50 in start_thread () from 
/lib/x86_64-linux-gnu/libpthread.so.0
#16 0x00007fbeb9eb395d in clone () from /lib/x86_64-linux-gnu/libc.so.6
#17 0x0000000000000000 in ?? ()

In both cases, the thread is waiting in recvmsg.

Stefan

>
> Thanks,
>
> 	tglx
>
