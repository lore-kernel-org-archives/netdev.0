From: Thomas Meyer <thomas@m3y3r.de>
Subject: Re: 2.6.21 known regressions (v2) (for -stable team)
Date: Sat, 28 Apr 2007 20:03:07 +0200
Message-ID: <46338C5B.4010809@m3y3r.de>
References: <463375E5.5040108@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org,
	Riccardo Ricci <rricci@nuovanetmore.it>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	Len Brown <len.brown@intel.com>,
	David Brownell <david-b@pacbell.net>,
	Jeff Mahoney <jeffm@suse.com>, reiserfs-dev@namesys.com,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	Francois SIMOND <curio@free.fr>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	=?UTF-8?B?SMOla2FuIExpbmRxdmlzdA==?= <lindqvist@netstar.se>,
	Vincent Frentzel <zcecc22@ucl.ac.uk>,
	=?UTF-8?B?RnJhbsOnb2lzIFZhbGVuZHVj?= <francois.valenduc@skynet.be>,
	Thomas Meyer <thomas.mey@web.de>,
	Giorgio Lando <patroclo7@gmail.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1163363AbXD1SE4@vger.kernel.org>
In-Reply-To: <463375E5.5040108@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Piotrowski schrieb:
> Subject    : Bad interaction between dynticks and amarok?
> References : http://lkml.org/lkml/2007/4/26/307
> Submitter  : Thomas Meyer <thomas.mey@web.de>
> Status     : Unknow
>
>   
Please remove this from the regression list. This seems to be an
userspace only problem and is not related to any kernel driver:
amarok and/or audacious seems to repeatedly read/write to the X socket:

tail of the strace of audacious:
gettimeofday({1177782978, 24491}, NULL) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 581502867}) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 581614815}) = 0
select(4, [3], [3], NULL, NULL)         = 1 (out [3])
writev(3,
[{"\221\3\n\0\3\0\200\2#\0\200\2\0\6@\0\240\4\20\0L\0\20\0"..., 40}], 1)
= 40
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 25286}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 9) = 0
gettimeofday({1177782978, 33242}, NULL) = 0
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 33475}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 1) = 0
gettimeofday({1177782978, 36548}, NULL) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 593554129}) = 0
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 36921}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 9) = 0
gettimeofday({1177782978, 46572}, NULL) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 603578038}) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 603689148}) = 0
select(4, [3], [3], NULL, NULL)         = 1 (out [3])
writev(3, [{"\221\3\n\0\3\0\200\2#\0\200\2\0\6@\0\0\4 \0L\0\20\0\23"...,
40}], 1) = 40
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 47341}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 9) = 0
gettimeofday({1177782978, 56566}, NULL) = 0
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 56799}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 0) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 613921380}) = 0
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 57282}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 9) = 0
gettimeofday({1177782978, 67696}, NULL) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 624704202}) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 624817966}) = 0
select(4, [3], [3], NULL, NULL)         = 1 (out [3])
writev(3, [{"\221\3\n\0\3\0\200\2#\0\200\2\0\6@\0P\4
\0L\0\20\0\23\0"..., 40}], 1) = 40
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 68476}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 9) = 0
gettimeofday({1177782978, 76564}, NULL) = 0
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 76796}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 0) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 633919963}) = 0
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 77280}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}], 2, 9) = 0
gettimeofday({1177782978, 86898}, NULL) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 643911329}) = 0
clock_gettime(CLOCK_MONOTONIC, {224, 644025581}) = 0
select(4, [3], [3], NULL, NULL)         = 1 (out [3])
writev(3, [{"\221\3\n\0\3\0\200\2#\0\200\2\0\6@\0\240\4
\0L\0\20\0\23"..., 40}], 1) = 40
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 87702}, NULL) = 0
poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN, revents=POLLIN}], 2,
9) = 1
read(3, "\n\3P\v\4\0\200\2\0\0\0\0\210v\274\277r\300\10\10x\35!"...,
4096) = 96
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
read(3, 0x80da6c8, 4096)                = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1177782978, 90108}, NULL) = 0
gettimeofday({1177782978, 90163}, NULL) = 0

But i didn't have a look at what is going on here. But running amarok
and/or audacious (without playing a song!) adds 50-70 more interrupts to
the timer interrupt.

with kind regards
thomas
