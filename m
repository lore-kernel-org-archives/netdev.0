From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Csum and csum copyroutines benchmark
Date: Fri, 25 Oct 2002 11:59:06 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210250906.g9P96Yp14775@Port.imtp.ilyichevsk.odessa.ua>
References: <200210231218.18733.roy@karlsbakk.net> <200210250643.g9P6hop13980@Port.imtp.ilyichevsk.odessa.ua> <87n0p3x8lh.fsf@fadata.bg>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: Russell King <rmk@arm.linux.org.uk>,
   Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Momchil Velikov <velco@fadata.bg>
In-Reply-To: <87n0p3x8lh.fsf@fadata.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[please drop libc from CC:]

On 25 October 2002 05:48, Momchil Velikov wrote:
>> Short conclusion:
>> 1. It is possible to speed up csum routines for AMD processors
>>    by 30%.
>> 2. It is possible to speed up csum_copy routines for both AMD
>>    andd Intel three times or more.

> Additional data point:
>
> Short summary:
> 1. Checksum - kernelpii_csum is ~19% faster
> 2. Copy - lernelpii_csum is ~6% faster
>
> Dual Pentium III, 1266Mhz, 512K cache, 2G SDRAM (133Mhz, ECC)
>
> The only changes I made were to decrease the buffer size to 1K (as I
> think this is more representative to a network packet size, correct
> me if I'm wrong) and increase the runs to 1024. Max values are
> worthless indeed.

Well, that makes it run entirely in L0 cache. This is unrealistic
for actual use. movntq is x3 faster when you hit RAM instead of L0.

You need to be more clever than that - generate pseudo-random
offsets in large buffer and run on ~1K pieces of that buffer.

> HOWEVER ...
>
> sometimes (say 1/30) I get the following output:

Csum benchmark program
buffer size: 1 K
Each test tried 1024 times, max and min CPU cycles are reported.
Please disregard max values. They are due to system interference only.
csum tests:
                     kernel_csum - took   958 max,  740 min cycles per kb. sum=0x44000077
                     kernel_csum - took   748 max,  740 min cycles per kb. sum=0x44000077
                     kernel_csum - took   752 max,  740 min cycles per kb. sum=0x44000077
                  kernelpii_csum - took   624 max,  600 min cycles per kb. sum=0x44000077
                kernelpiipf_csum - took 877211 max,  601 min cycles per kb. sum=0x44000077
Bad sum
Aborted

> which is to say that pfm_csum and pfm2_csum results are not to be
> trusted (at least on PIII (or my kernel CONFIG_MPENTIUMIII=y
> config?)).

No, it's my fault. Those routines are fast-hacked together, they
are actually can csym too little. I didn't get to handle arbitrary
buffer length, assuming it it a large power of two. See the source.
--
vda
