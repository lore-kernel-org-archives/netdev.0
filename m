From: Momchil Velikov <velco@fadata.bg>
Subject: Re: Csum and csum copyroutines benchmark
Date: 25 Oct 2002 10:48:10 +0300
Sender: libc-alpha-owner@sources.redhat.com
Message-ID: <87n0p3x8lh.fsf@fadata.bg>
References: <200210231218.18733.roy@karlsbakk.net>
	<20021024125030.A7529@flint.arm.linux.org.uk>
	<200210241249.g9OCnOp09750@Port.imtp.ilyichevsk.odessa.ua>
	<200210250643.g9P6hop13980@Port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk@arm.linux.org.uk>,
  Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com,
  Kernel mailing list <linux-kernel@vger.kernel.org>,
  libc-alpha@sources.redhat.com
Return-path: <libc-alpha-return-10165-glibc-alpha=m.gmane.org@sources.redhat.com>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sources.redhat.com>
List-Subscribe: <mailto:libc-alpha-subscribe@sources.redhat.com>
List-Archive: <http://sources.redhat.com/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sources.redhat.com>
List-Help: <mailto:libc-alpha-help@sources.redhat.com>, <http://sources.redhat.com/ml/#faqs>
To: vda@port.imtp.ilyichevsk.odessa.ua
In-Reply-To: <200210250643.g9P6hop13980@Port.imtp.ilyichevsk.odessa.ua>
List-Id: netdev.vger.kernel.org

>>>>> "Denis" == Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> writes:

Denis> /me said:
>> I'm experimenting with different csum_ routines in userspace now.

Denis> Short conclusion: 
Denis> 1. It is possible to speed up csum routines for AMD processors by 30%.
Denis> 2. It is possible to speed up csum_copy routines for both AMD and Intel
Denis>    three times or more. Roy, do you like that? ;)

Additional data point:

Short summary:
1. Checksum - kernelpii_csum is ~19% faster
2. Copy - lernelpii_csum is ~6% faster

Dual Pentium III, 1266Mhz, 512K cache, 2G SDRAM (133Mhz, ECC)

The only changes I made were to decrease the buffer size to 1K (as I
think this is more representative to a network packet size, correct me
if I'm wrong) and increase the runs to 1024. Max values are worthless
indeed.


Csum benchmark program
buffer size: 1 K
Each test tried 1024 times, max and min CPU cycles are reported.
Please disregard max values. They are due to system interference only.
csum tests:
                     kernel_csum - took   941 max,  740 min cycles per kb. sum=0x44000077
                     kernel_csum - took   748 max,  742 min cycles per kb. sum=0x44000077
                     kernel_csum - took 60559 max,  742 min cycles per kb. sum=0x44000077
                  kernelpii_csum - took 52804 max,  601 min cycles per kb. sum=0x44000077
                kernelpiipf_csum - took 12930 max,  601 min cycles per kb. sum=0x44000077
                        pfm_csum - took 10161 max, 1402 min cycles per kb. sum=0x44000077
                       pfm2_csum - took   864 max,  838 min cycles per kb. sum=0x44000077
copy tests:
                     kernel_copy - took   339 max,  239 min cycles per kb. sum=0x44000077
                     kernel_copy - took   239 max,  239 min cycles per kb. sum=0x44000077
                     kernel_copy - took   239 max,  239 min cycles per kb. sum=0x44000077
                  kernelpii_copy - took   244 max,  225 min cycles per kb. sum=0x44000077
                      ntqpf_copy - took 10867 max,  512 min cycles per kb. sum=0x44000077
                     ntqpfm_copy - took   710 max,  403 min cycles per kb. sum=0x44000077
                        ntq_copy - took  4535 max,  443 min cycles per kb. sum=0x44000077
                     ntqpf2_copy - took   563 max,  555 min cycles per kb. sum=0x44000077
Done


HOWEVER ...

sometimes (say 1/30) I get the following output:

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

which is to say that pfm_csum and pfm2_csum results are not to be
trusted (at least on PIII (or my kernel CONFIG_MPENTIUMIII=y
config?)).

~velco
