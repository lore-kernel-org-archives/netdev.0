From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: Re: [Lksctp-developers] Re: [PATCH] subset of RFC2553
Date: Wed, 19 Feb 2003 19:28:50 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E542F52.50001@us.ibm.com>
References: <1045621941.1253.21.camel@w-bwa1.beaverton.ibm.com> <3E54128C.327D7759@us.ibm.com> <3E541FEA.C34BEEB7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Grimm <jgrimm2@us.ibm.com>,
	lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Bruce Allan <bwa@us.ibm.com>
List-Id: netdev.vger.kernel.org

Bruce,
    I removed Dave from the the cc list until we get something that 
works for us (or anyone else that wants to chime in).
    My second proposal doesn't look quite right when I reread it.    See 
below.

Thanks,
Jon

Jon Grimm wrote:

>Or if you don't care about the alignment of the __data field at all:
>
>#define _SS_MAXSIZE 128
>#if ULONG_MAX > 0xffffffff
>#define _ALIGNSIZE ((sizeof(__u64)))
>#else
>#define _ALIGNSIZE ((sizeof(__u32)))
>#endif
>struct sockaddr_storage {
>	sa_family_t     ss_family;
>	char            __data[_SS_MAXSIZE-sizeof(sa_family_t)*2 + _ALIGNSIZE];
>

Should be
    char __data[__SS_MAXSIZE-ALIGNSIZE];

>} __attribute ((aligned(_ALIGNSIZE)));
>
>
>jon
>
>
>
>Jon Grimm wrote:
>  
>
>>Bruce Allan wrote:
>>    
>>
>>>How about this instead (a combination of your comment above and glibc's
>>>definition of sockaddr_storage):
>>>#define _SS_MAXSIZE     128
>>>#define _ALIGNSIZE      (sizeof(struct sockaddr *))
>>>#if ULONG_MAX > 0xffffffff
>>>#define __ss_aligntype  __u64
>>>#else
>>>#define __ss_aligntype  __u32
>>>#endif
>>>struct sockaddr_storage {
>>>        sa_family_t     ss_family;
>>>        __ss_aligntype  __data[(_SS_MAXSIZE/sizeof(__ss_aligntype))-1];
>>>} __attribute__ ((aligned(_ALIGNSIZE)));
>>>
>>>      
>>>
>>Hmmm... this seemed to generate a 124-byte struct instead of the stated
>>intent of 128.
>>
>>Maybe instead:
>>
>>#define _SS_MAXSIZE 128
>>#if ULONG_MAX > 0xffffffff
>>#define __ss_aligntype      __u64
>>#else
>>#define __ss_aligntype      __u32
>>#endif
>>#define _ALIGNSIZE (sizeof(__ss_aligntype))
>>struct sockaddr_storage {
>>        sa_family_t     ss_family;
>>        __ss_aligntype  __data[_SS_MAXSIZE/_ALIGNSIZE-1] __attribute__
>>((aligned(_ALIGNSIZE)));
>>} __attribute ((aligned(_ALIGNSIZE)));
>>
>>Align the struct on _ALIGNSIZE; align _data on _ALIGNSIZE to to generate
>>padding between ss_family and __data.
>>
>>Best Regards,
>>jon
>>
>>-------------------------------------------------------
>>This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
>>The most comprehensive and flexible code editor you can use.
>>Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
>>www.slickedit.com/sourceforge
>>_______________________________________________
>>Lksctp-developers mailing list
>>Lksctp-developers@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/lksctp-developers
>>    
>>
>
>
>-------------------------------------------------------
>This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
>The most comprehensive and flexible code editor you can use.
>Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
>www.slickedit.com/sourceforge
>_______________________________________________
>Lksctp-developers mailing list
>Lksctp-developers@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/lksctp-developers
>
>  
>


