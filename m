From: "David S. Miller" <davem@redhat.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Wed, 23 Jul 2003 03:13:51 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030723031351.4e9db07c.davem@redhat.com>
References: <200307210155.FAA31320@dub.inr.ac.ru>
	<Pine.LNX.4.44.0307221415140.14683-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, krkumar@us.ibm.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0307221415140.14683-100000@DYN318430.beaverton.ibm.com>
List-Id: netdev.vger.kernel.org

On Tue, 22 Jul 2003 14:50:21 -0700 (PDT)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> I am using sizeof(struct xxx) or __u32, etc in the code, I guess you are
> ok with that.

This needs some fixes still.  First thing, ipv6_devconf is not
obtainable from user and has pointers in it which makes usage sloppy.
So I would suggest the following:

1) Remove "void *sysctl;" from ipv6_devconf, move it into
   inet6_dev ie. "void *cnf_sysctl;" update all code users.

2) Move "struct ipv6_devconf" into some linux/*.h ipv6 header
   usable by users.  Use an existing one if possible.  Then
   make sure net/if_inet6.h includes this thing.

3) Change "int" members of struct "ipv6_devconf" to "s32".
   It's anal and unnecessary on any current platform, but
   some day with 128-bit computers it might make some difference.
   :-)

Thanks.
