From: Ben Pfaff <blp@cs.stanford.edu>
Subject: Re: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Wed, 15 Aug 2012 09:52:53 -0700
Message-ID: <87wr102j2y.fsf@blp.benpfaff.org>
References: <20120815161141.7598.16682.stgit@localhost.localdomain>
Reply-To: blp@cs.stanford.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, mingo@redhat.com, davem@davemloft.net,
	hpa@zytor.com, thierry.reding@avionic-design.de,
	bfields@redhat.com, eric.dumazet@gmail.com, xemul@parallels.com,
	neilb@suse.de, netdev@vger.kernel.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	akpm@linux-foundation.org, tim.c.chen@linux.intel.com,
	devel@openvz.org, ebiederm@xmission.com
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120815161141.7598.16682.stgit@localhost.localdomain>
	(Stanislav Kinsbursky's message of "Wed, 15 Aug 2012 20:21:56 +0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanislav Kinsbursky <skinsbursky@parallels.com> writes:

> This system call is especially required for UNIX sockets, which has name
> lenght limitation.

The worst of the name length limitations can be worked around by
opening the directory where the socket is to go as a file
descriptor, then using /proc/self/fd/<fd>/<basename> as the name
of the socket.  This technique also works with "connect" and in
other contexts where a struct sockaddr is needed.  At first
glance, it looks like your patches only help with "bind".
