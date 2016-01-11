From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 11/53] perf test: Fix false TEST_OK result for 'perf test
 hist'
Date: Mon, 11 Jan 2016 12:32:37 -0300
Message-ID: <20160111153237.GD18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-12-git-send-email-wangnan0@huawei.com>
 <5693BB6C.9060900@cogentembedded.com>
 <20160111145837.GC21083@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, linux-kernel@vger.kernel.org,
	pi3orama@163.com, lizefan@huawei.com, netdev@vger.kernel.org,
	davem@davemloft.net, Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160111145837.GC21083@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 12:58:37PM -0200, Arnaldo Carvalho de Melo escreveu:
> Em Mon, Jan 11, 2016 at 05:25:48PM +0300, Sergei Shtylyov escreveu:
> > On 01/11/2016 04:48 PM, Wang Nan wrote:
> > 
> > >Commit 71d6de64feddd4b455555326fba2111b3006d9e0 ('perf test: Fix hist
> > >testcases when kptr_restrict is on') solves a double free problem when
> > 
> >    You didn't run this patch thru scripts/checkpatch.pl, I guess? A
> > certain commit citing style is enforced now, and yours doesn't quite
> > match it...
> 
> Which is? /me goes to read checpatch.pl...

So, this is it:

[acme@felicio linux]$ scripts/checkpatch.pl /wb/1.patch 
ERROR: Please use git commit description style 'commit <12+ chars of
sha1> ("<title line>")' - ie: 'Commit 71d6de64fedd ("perf test: Fix hist
testcases when kptr_restrict is on")'
#62: 
Commit 71d6de64feddd4b455555326fba2111b3006d9e0 ('perf test: Fix hist

total: 1 errors, 0 warnings, 11 lines checked

/wb/1.patch has style problems, please review.

NOTE: If any of the errors are false positives, please report
      them to the maintainer, see CHECKPATCH in MAINTAINERS.
[acme@felicio linux]$ 

Ok, matches what I use with this macro that I run in vim with ':!fixes'
after selecting the long commit hash:

#!/bin/bash

if [ $# -eq 1 ] ; then
	cset=$1
else
	read cset
fi
git log --oneline $cset | head -1 | sed -r 's/([^ ]+) (.*)/Fixes: \1 \("\2\")/g'

------------------------

And I have:

[acme@felicio linux]$ grep abbrev .git/config
	abbrev = 12

- Arnaldo
