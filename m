From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 13/53] perf tools: Prevent calling machine__delete() on
 non-allocated machine
Date: Tue, 12 Jan 2016 11:07:15 -0300
Message-ID: <20160112140715.GN18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-14-git-send-email-wangnan0@huawei.com>
 <20160111154202.GE18367@kernel.org>
 <5694A54B.3090209@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5694A54B.3090209@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Jan 12, 2016 at 03:03:39PM +0800, Wangnan (F) escreveu:
> On 2016/1/11 23:42, Arnaldo Carvalho de Melo wrote:
> >Em Mon, Jan 11, 2016 at 01:48:04PM +0000, Wang Nan escreveu:
> >>To prevent futher commits calling machine__delete() on non-allocated
> >>'struct machine' (which would cause memory corruption), this patch
> >>enforces machine__init(), record whether a machine structure is
> >>dynamically allocated or not, and warn if machine__delete() is called
> >>on incorrect object.
> >Not sure on this one, I think I voiced this before, this seems like
> >something to be tested using some static analysis tool or even checking
> >if the address for the struct hitting machine__delete() is from malloc
> >or not.
> >
> >I.e. if we do it here, we may have to do it to any other struct where we
> >allocate it in the stack or via malloc, and furthermore there are cases
> >where we embed a struct in another, when we would free just the main
> >struct but not the second, embedded one, that would need just calling
> >foo__exit() and not foo__delete().

> OK. Let's drop this one.

I'll let a note in my TODO list to improve this situation, dropping the
rename, thanks for the resent patch with just the fix.

Try to do it like that in the future, if possible, i.e. one thing per
patch, one with the super-minimal fix, anything else in a separate
patch.

- Arnaldo
