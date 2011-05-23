From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [v3 00/39] faster tree-based sysctl implementation
Date: Sun, 22 May 2011 21:27:14 -0700
Message-ID: <m14o4mavod.fsf@fess.ebiederm.org>
References: <BANLkTim7xn8tM4wTyd_m_nwUQg_CUTapeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTim7xn8tM4wTyd_m_nwUQg_CUTapeA@mail.gmail.com> (Lucian
	Adrian Grijincu's message of "Mon, 23 May 2011 04:56:11 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lucian Adrian Grijincu <lucian.grijincu@gmail.com> writes:

> Hi
>
> This is version 3 of a patch series that introduces a faster/leaner
> sysctl internal implementation.
>
> Due to high number of patches and low general interest I'll just point
> you to the tree/branch:
>
>   git://github.com/luciang/linux-2.6-new-sysctl.git   v3-new-sysctl-alg
>
>
> Patches are on top of v2.6.39. I did not pick a more recent (random)
> point in Linus' tree to rebase these onto to not mess up testing.


Thanks for keeping going on this.

This patchset looks like it is deserving of some close scrutiny, and
not just the high level design overview I have given the previous
patches.  This is going to be a busy week for me so I probably won't
get through all of the patches for a while.

I will mention a couple of nits I noticed while I was skimming through
your patches.
- There can be multiple proc superblocks and thus multiple inodes
  referring to the same /proc/sys file, if there are multiple pid
  namespaces. 

- I have a hope to move /proc/sys into /proc/<pid>/sys so we don't have
  to look at current to determine the namespace we want to display.
  That would allow the deeply magic sysctl_is_seen check to be removed
  from proc_sys_compare.  That is not your problem, but of an
  explanation why the namespaces are passed through.

Eric
