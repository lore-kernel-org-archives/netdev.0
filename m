From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: [Lksctp-developers] Re: [PATCH] subset of RFC2553
Date: Thu, 20 Feb 2003 12:53:55 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E554063.3010008@us.ibm.com>
References: <1045621941.1253.21.camel@w-bwa1.beaverton.ibm.com> <3E54128C.327D7759@us.ibm.com> <3E541FEA.C34BEEB7@us.ibm.com> <3E542F52.50001@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Jon Grimm <jgrimm2@us.ibm.com>
In-Reply-To: <3E542F52.50001@us.ibm.com>
List-Id: netdev.vger.kernel.org

After re-reading this thread, I think what Dave didn't like about the 
original definition of sockaddr_storage was the unnecessary use of 
 _more_than_1_ pad field and the align field.  So, the simplest 
definition that Dave might approve would be:

#define _SS_MAXSIZE  128  /* Implementation specific max size */
struct sockaddr_storage {
        sa_family_t      ss_family;
        char                 __data[_SS_MAXSIZE - sizeof(sa_family_t)];
} __attribute __ ((aligned(sizeof(struct sockaddr *))));

The use of the 'sizeof(struct sockaddr *)' for specifying the required 
alignment is just to illustrate the second criteria for this structure 
as documented in the RFC, i.e. "It is aligned at an appropriate boundary 
so protocol specific socket address data structure pointers can be cast 
to it and access their fields without alignment problems...".

I'll resubmit a patch tomorrow with the above definition if there are no 
objections.

Bruce Allan

Jon Grimm wrote:

> Bruce,
>    I removed Dave from the the cc list until we get something that 
> works for us (or anyone else that wants to chime in).
>    My second proposal doesn't look quite right when I reread it.    
> See below.
>
> Thanks,
> Jon
>
> Jon Grimm wrote:
>
>> Or if you don't care about the alignment of the __data field at all:
>>
>> #define _SS_MAXSIZE 128
>> #if ULONG_MAX > 0xffffffff
>> #define _ALIGNSIZE ((sizeof(__u64)))
>> #else
>> #define _ALIGNSIZE ((sizeof(__u32)))
>> #endif
>> struct sockaddr_storage {
>>     sa_family_t     ss_family;
>>     char            __data[_SS_MAXSIZE-sizeof(sa_family_t)*2 + 
>> _ALIGNSIZE];
>>
>
> Should be
>    char __data[__SS_MAXSIZE-ALIGNSIZE];
>
>> } __attribute ((aligned(_ALIGNSIZE)));
>>
>>
>> jon
>

