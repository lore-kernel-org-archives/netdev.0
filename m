From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Wed, 15 Aug 2012 10:54:15 -0700
Message-ID: <502BE247.7000308@zytor.com>
References: <20120815161141.7598.16682.stgit@localhost.localdomain> <87wr102j2y.fsf@blp.benpfaff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
	tglx@linutronix.de, mingo@redhat.com, davem@davemloft.net,
	thierry.reding@avionic-design.de, bfields@redhat.com,
	eric.dumazet@gmail.com, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	akpm@linux-foundation.org, tim.c.chen@linux.intel.com,
	devel@openvz.org, ebiederm@xmission.com
To: blp@cs.stanford.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wr102j2y.fsf@blp.benpfaff.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2012 09:52 AM, Ben Pfaff wrote:
> Stanislav Kinsbursky <skinsbursky@parallels.com> writes:
> 
>> This system call is especially required for UNIX sockets, which has name
>> lenght limitation.
> 
> The worst of the name length limitations can be worked around by
> opening the directory where the socket is to go as a file
> descriptor, then using /proc/self/fd/<fd>/<basename> as the name
> of the socket.  This technique also works with "connect" and in
> other contexts where a struct sockaddr is needed.  At first
> glance, it looks like your patches only help with "bind".
> 

The really hard part is what to do with things that are supposed to
return a struct sockaddr.  I also have some reservations about using a
new system call to deal with what at least theoretically is only part of
one socket domain.

	-hpa
