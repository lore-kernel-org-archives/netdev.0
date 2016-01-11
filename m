From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 05/53] perf tools: Test correct path of perf in build-test
Date: Mon, 11 Jan 2016 12:24:56 -0300
Message-ID: <20160111152456.GC18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-6-git-send-email-wangnan0@huawei.com>
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
In-Reply-To: <1452520124-2073-6-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 01:47:56PM +0000, Wang Nan escreveu:
> If an 'O' is passed to 'make build-test', many 'test -x' and 'test -f=
'
> will fail because perf resides in a different directory. Fix this by
> computing PERF_OUT according to 'O' and test correct output files.
> For make_kernelsrc and make_kernelsrc_tools, set KBUILD_OUTPUT_DIR
> instead because the path is different from others ($(O)/perf vs
>  $(O)/tools/perf).

Ok, applying up to this patch I now manage to almost cleanly build it u=
sing O=3D,
see below, but seems that we have some race, as not all tests end up pr=
oducing
such warnings.

[acme@felicio linux]$ rm -rf /tmp/build/perf ; mkdir -p /tmp/build/perf=
 ; make O=3D/tmp/build/perf -C tools/perf build-test
make: Entering directory `/home/acme/git/linux/tools/perf'
Testing Makefile
- make_no_libperl: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.m1nXBM=
qhSA NO_LIBPERL=3D1
find: =E2=80=98/tmp/build/perf/util/trace-event-scripting.o=E2=80=99: N=
o such file or directory
find: =E2=80=98/tmp/build/perf/util/build-id.o=E2=80=99: No such file o=
r directory
- make_no_libdw_dwarf_unwind: cd . && make -f Makefile   DESTDIR=3D/tmp=
/tmp.RB7Ile9C0b NO_LIBDW_DWARF_UNWIND=3D1
- make_no_backtrace: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.HeNp=
C0PW1O NO_BACKTRACE=3D1
find: =E2=80=98/tmp/build/perf/util/trace-event-scripting.o=E2=80=99: N=
o such file or directory
find: =E2=80=98/tmp/build/perf/util/alias.o=E2=80=99: No such file or d=
irectory
- make_install_prefix: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.JP=
K5a72h53 install prefix=3D/tmp/krava
find: =E2=80=98/tmp/build/perf/libapi.a=E2=80=99: No such file or direc=
tory
- make_help: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.F3Z0qPtslS h=
elp
- make_doc: cd . && make -f Makefile   DESTDIR=3D/tmp/tmp.6a2HbvC2ej do=
c
