From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: Re: [Lksctp-developers] Re: [PATCH] subset of RFC2553
Date: Wed, 19 Feb 2003 17:26:04 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E54128C.327D7759@us.ibm.com>
References: <1045621941.1253.21.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, lksctp-developers@lists.sourceforge.net,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bruce Allan <bwa@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bruce Allan wrote:
> 
> How about this instead (a combination of your comment above and glibc's
> definition of sockaddr_storage):
> #define _SS_MAXSIZE     128
> #define _ALIGNSIZE      (sizeof(struct sockaddr *))
> #if ULONG_MAX > 0xffffffff
> #define __ss_aligntype  __u64
> #else
> #define __ss_aligntype  __u32
> #endif
> struct sockaddr_storage {
>         sa_family_t     ss_family;
>         __ss_aligntype  __data[(_SS_MAXSIZE/sizeof(__ss_aligntype))-1];
> } __attribute__ ((aligned(_ALIGNSIZE)));
> 


Hmmm... this seemed to generate a 124-byte struct instead of the stated
intent of 128.


Maybe instead:

#define _SS_MAXSIZE 128
#if ULONG_MAX > 0xffffffff
#define __ss_aligntype      __u64
#else
#define __ss_aligntype      __u32
#endif
#define _ALIGNSIZE (sizeof(__ss_aligntype))
struct sockaddr_storage {
	sa_family_t     ss_family;
	__ss_aligntype  __data[_SS_MAXSIZE/_ALIGNSIZE-1] __attribute__
((aligned(_ALIGNSIZE)));
} __attribute ((aligned(_ALIGNSIZE)));



Align the struct on _ALIGNSIZE; align _data on _ALIGNSIZE to to generate
padding between ss_family and __data.

Best Regards,
jon
