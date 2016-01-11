From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 11/53] perf test: Fix false TEST_OK result for 'perf test
 hist'
Date: Mon, 11 Jan 2016 12:58:37 -0200
Message-ID: <20160111145837.GC21083@redhat.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-12-git-send-email-wangnan0@huawei.com>
 <5693BB6C.9060900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, acme@kernel.org,
	linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5693BB6C.9060900@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 05:25:48PM +0300, Sergei Shtylyov escreveu:
> On 01/11/2016 04:48 PM, Wang Nan wrote:
> 
> >Commit 71d6de64feddd4b455555326fba2111b3006d9e0 ('perf test: Fix hist
> >testcases when kptr_restrict is on') solves a double free problem when
> 
>    You didn't run this patch thru scripts/checkpatch.pl, I guess? A
> certain commit citing style is enforced now, and yours doesn't quite
> match it...

Which is? /me goes to read checpatch.pl...

- Arnaldo
 
> >'perf test hist' calling setup_fake_machine(). However, the result is
> >still incorrect. For example:
> >
> >  $ ./perf test -v 'filtering hist entries'
> >  25: Test filtering hist entries                              :
> >  --- start ---
> >  test child forked, pid 4186
> >  Cannot create kernel maps
> >  test child finished with 0
> >  ---- end ----
> >  Test filtering hist entries: Ok
> >
> >In this case the body of this test is not get executed at all, but the
> >result is 'Ok'.
> >
> >Actually, in setup_fake_machine() there's no need to create real kernel
> >maps. What we want is the fake maps. This patch removes the
> >machine__create_kernel_maps() in setup_fake_machine(), so it won't be
> >affected by kptr_restrict setting.
> >
> >Test result:
> >
> >  $ cat /proc/sys/kernel/kptr_restrict
> >  1
> >  $ ~/perf test -v hist
> >  15: Test matching and linking multiple hists                 :
> >  --- start ---
> >  test child forked, pid 24031
> >  test child finished with 0
> >  ---- end ----
> >  Test matching and linking multiple hists: Ok
> >  [SNIP]
> >
> >Signed-off-by: Wang Nan <wangnan0@huawei.com>
> >Suggested-by: Namhyung Kim <namhyung@kernel.org>
> >Acked-by: Namhyung Kim <namhyung@kernel.org>
> >Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> >Cc: Jiri Olsa <jolsa@kernel.org>
> >Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
> [...]
> 
> MBR, Sergei
