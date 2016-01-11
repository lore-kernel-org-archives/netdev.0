From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 05/53] perf tools: Test correct path of perf in build-test
Date: Mon, 11 Jan 2016 19:06:18 -0300
Message-ID: <20160111220618.GK18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-6-git-send-email-wangnan0@huawei.com>
 <20160111152456.GC18367@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Jiri Olsa <jolsa@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160111152456.GC18367@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 12:24:56PM -0300, Arnaldo Carvalho de Melo escr=
eveu:
> Em Mon, Jan 11, 2016 at 01:47:56PM +0000, Wang Nan escreveu:
> > If an 'O' is passed to 'make build-test', many 'test -x' and 'test =
-f'
> > will fail because perf resides in a different directory. Fix this b=
y
> > computing PERF_OUT according to 'O' and test correct output files.
> > For make_kernelsrc and make_kernelsrc_tools, set KBUILD_OUTPUT_DIR
> > instead because the path is different from others ($(O)/perf vs
> >  $(O)/tools/perf).
>=20
> Ok, applying up to this patch I now manage to almost cleanly build it=
 using O=3D,
> see below, but seems that we have some race, as not all tests end up =
producing
> such warnings.
>=20
> [acme@felicio linux]$ rm -rf /tmp/build/perf ; mkdir -p /tmp/build/pe=
rf ; make O=3D/tmp/build/perf -C tools/perf build-test
> make: Entering directory `/home/acme/git/linux/tools/perf'
> Testing Makefile
> - make_no_libperl: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.m1nX=
BMqhSA NO_LIBPERL=3D1
> find: =E2=80=98/tmp/build/perf/util/trace-event-scripting.o=E2=80=99:=
 No such file or directory

Well, it is happening even without O=3D:


[acme@felicio linux]$ perf stat make -C tools/perf build-test
make: Entering directory `/home/acme/git/linux/tools/perf'
Testing Makefile
- make_doc: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.H8z3S3cEJ0 do=
c
- make_install_bin: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.njIAP=
XMF7f install-bin
- make_install_prefix: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.9F=
EKGBoeyN install prefix=3D/tmp/krava
- make_no_gtk2: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.nHl593wfM=
P NO_GTK2=3D1
- make_util_map_o: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.ZSmZP4=
90hX util/map.o
- make_no_slang: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.7q24C1xm=
cu NO_SLANG=3D1
- make_pure: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.R51cy8kdWl=20
- make_no_libpython: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.3t9t=
Ec0e4b NO_LIBPYTHON=3D1
- make_no_libbionic: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.4yYe=
lFUaq0 NO_LIBBIONIC=3D1
- make_no_newt: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.3Fg7hv3Hn=
1 NO_NEWT=3D1
- make_tags: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.8WMgskFkOH t=
ags
- make_install: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.YQq3wOEky=
B install
- make_no_libdw_dwarf_unwind: cd . && make -f Makefile   DESTDIR=3D/tmp=
/tmp.WKRVFDA2ty NO_LIBDW_DWARF_UNWIND=3D1
find: =E2=80=98/home/acme/git/linux/tools/perf/.gtk-in.o.cmd=E2=80=99: =
No such file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/builtin-script.o=E2=80=99=
: No such file or directory
- make_no_libunwind: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.SQft=
zGTUYf NO_LIBUNWIND=3D1
- make_no_auxtrace: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.Xy2xr=
SCVuO NO_AUXTRACE=3D1
- make_no_ui: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.ZFNEHWqQFN =
NO_NEWT=3D1 NO_SLANG=3D1 NO_GTK2=3D1
- make_no_libnuma: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.68zRtM=
aEqf NO_LIBNUMA=3D1
- make_no_backtrace: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.5xce=
a8XfdC NO_BACKTRACE=3D1
find: =E2=80=98/home/acme/git/linux/tools/perf/arch/x86/tests/dwarf-unw=
ind.o=E2=80=99: No such file or directory
- make_install_prefix_slash: cd . && make -f Makefile   DESTDIR=3D/tmp/=
tmp.2c5BqUKGef install prefix=3D/tmp/krava/
find: =E2=80=98/home/acme/git/linux/tools/perf/builtin-record.o=E2=80=99=
: No such file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/builtin-inject.o=E2=80=99=
: No such file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/builtin-bench.o=E2=80=99=
: No such file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/.builtin-lock.o.cmd=E2=80=
=99: No such file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/perf.o=E2=80=99: No such=
 file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/scripts/.libperf-in.o.cm=
d=E2=80=99: No such file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/tests/evsel-tp-sched.o=E2=
=80=99: No such file or directory
find: =E2=80=98/home/acme/git/linux/tools/perf/tests/hists_cumulate.o=E2=
=80=99: No such file or directory
- make_util_pmu_bison_o: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.=
aJUWyFbXsp util/pmu-bis
