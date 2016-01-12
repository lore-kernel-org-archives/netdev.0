From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 05/53] perf tools: Test correct path of perf in build-test
Date: Tue, 12 Jan 2016 15:16:08 +0800
Message-ID: <5694A838.6030307@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com> <1452520124-2073-6-git-send-email-wangnan0@huawei.com> <20160111152456.GC18367@kernel.org> <20160111220618.GK18367@kernel.org> <20160111223904.GL18367@kernel.org> <20160111223954.GM18367@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Jiri Olsa <jolsa@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111223954.GM18367@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/1/12 6:39, Arnaldo Carvalho de Melo wrote:
> Em Mon, Jan 11, 2016 at 07:39:04PM -0300, Arnaldo Carvalho de Melo es=
creveu:
>> Em Mon, Jan 11, 2016 at 07:06:18PM -0300, Arnaldo Carvalho de Melo e=
screveu:
>>> Em Mon, Jan 11, 2016 at 12:24:56PM -0300, Arnaldo Carvalho de Melo =
escreveu:
>>>> Em Mon, Jan 11, 2016 at 01:47:56PM +0000, Wang Nan escreveu:
>>>>> If an 'O' is passed to 'make build-test', many 'test -x' and 'tes=
t -f'
>>>>> will fail because perf resides in a different directory. Fix this=
 by
>>>>> computing PERF_OUT according to 'O' and test correct output files=
=2E
>>>>> For make_kernelsrc and make_kernelsrc_tools, set KBUILD_OUTPUT_DI=
R
>>>>> instead because the path is different from others ($(O)/perf vs
>>>>>   $(O)/tools/perf).
>>>> Ok, applying up to this patch I now manage to almost cleanly build=
 it using O=3D,
>>>> see below, but seems that we have some race, as not all tests end =
up producing
>>>> such warnings.
>>>>
>>>> [acme@felicio linux]$ rm -rf /tmp/build/perf ; mkdir -p /tmp/build=
/perf ; make O=3D/tmp/build/perf -C tools/perf build-test
>>>> make: Entering directory `/home/acme/git/linux/tools/perf'
>>>> Testing Makefile
>>>> - make_no_libperl: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.m=
1nXBMqhSA NO_LIBPERL=3D1
>>>> find: =E2=80=98/tmp/build/perf/util/trace-event-scripting.o=E2=80=99=
: No such file or directory

This can happen when you parallelly run find and rm on one directory.=20
However,
I've never seen this message in build-test before.

>>> Well, it is happening even without O=3D:
>> So I removed a few patches and those aren't appearing anymore, pleas=
e
>> take a look at my perf/core branch, running build-test on a few mach=
ines
>> now, will push soon.
>>
>> My hunch is that build-test has issues with parallel builds, but I'm=
 not
>> sure...
>
> Good:
>
> - make_perf_o_O: cd . && make -f Makefile O=3D/tmp/tmp.oLeg8aUaOo DES=
TDIR=3D/tmp/tmp.16WP4HTQJs perf.o
> - make_util_pmu_bison_o_O: cd . && make -f Makefile O=3D/tmp/tmp.xNRV=
0pCXfD DESTDIR=3D/tmp/tmp.8dyU9uEbHe util/pmu-bison.o
> - make_no_libdw_dwarf_unwind_O: cd . && make -f Makefile O=3D/tmp/tmp=
=2EpHH4HExHcH DESTDIR=3D/tmp/tmp.Wo0m8fF5cp NO_LIBDW_DWARF_UNWIND=3D1
> - make_no_demangle_O: cd . && make -f Makefile O=3D/tmp/tmp.yWNsd4jOs=
I DESTDIR=3D/tmp/tmp.Q7eA4kCvwL NO_DEMANGLE=3D1
> - tarpkg: ./tests/perf-targz-src-pkg .
> - make -C <kernelsrc> tools/perf
> - make -C <kernelsrc>/tools perf
> OK
Glad to see this.

Thank you.
