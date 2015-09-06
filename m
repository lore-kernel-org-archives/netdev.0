From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/core/sysctl_net_core.c  unused variable
Date: Sun, 06 Sep 2015 08:51:54 -0700
Message-ID: <1441554714.28194.49.camel@perches.com>
References: <55EC4A03.905@linicks.net>
	 <1441551148.28194.40.camel@perches.com> <55EC58DF.6020501@linicks.net>
	 <1441553310.28194.44.camel@perches.com> <55EC5D6B.3030402@linicks.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey Kodanev <alexey.kodanev@oracle.com>
To: Nick Warne <nick@linicks.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55EC5D6B.3030402@linicks.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-09-06 at 16:36 +0100, Nick Warne wrote:
> On 06/09/15 16:28, Joe Perches wrote:
> > On Sun, 2015-09-06 at 16:16 +0100, Nick Warne wrote:
> >> On 06/09/15 15:52, Joe Perches wrote:
> >> > On Sun, 2015-09-06 at 15:13 +0100, Nick Warne wrote:
> >> >> gcc version 4.8.2 (GCC) warns that 'static int one = 1;' is declared but
> >> >> not used in file net/core/sysctl_net_core.c.
> >> >
> >> > Only when CONFIG_NET isn't set.
> >>
> >> CONFIG_NET=y
> >>
> >> Peculiar indeed.
> >>
> >> >> Reading the file, that is
> >> >> the case.  Attached is a patch to remove it.
> >> >
> >> > $ git grep -w -n one net/core/sysctl_net_core.c
> >> > net/core/sysctl_net_core.c:26:static int one = 1;
> >> > net/core/sysctl_net_core.c:332:         .extra2         = &one
> >> >
> >> >> Signed-off-by:  Nick Warne <nick@linicks.net>
> >> >
> >> > Please use grep to augment reading.
> >>
> >> grep -w -n one net/core/sysctl_net_core.c
> >> 26:static int one = 1;
> >>
> >> ?
> >>
> >> I just don't have the &one.
> >>
> >> I am confused now.
> >
> > What source tree are you using?
> 
> Latest longterm 3.18.21

OK, it's important to mention that otherwise the
assumption would be a git tree like net or net-next.

> > What changes in what branch exist?
> 
> I am not using git (if that is what you mean by 'branches') - just 
> tarballs from kernel.org

(OK, using git and linux-stable)

$ git grep -w -n one v3.18.21 -- net/core/sysctl_net_core.c
v3.18.21:net/core/sysctl_net_core.c:26:static int one = 1;

And the responsible commit:

commit c48cf4f27d4555a455c3fef71137bd0fc44d1656
("net: sysctl_net_core: check SNDBUF and RCVBUF for min length")
