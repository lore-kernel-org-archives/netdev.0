From: "David S. Miller" <davem@redhat.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Thu, 24 Jul 2003 00:07:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030724000705.4662df54.davem@redhat.com>
References: <200307210155.FAA31320@dub.inr.ac.ru>
	<Pine.LNX.4.44.0307221415140.14683-100000@DYN318430.beaverton.ibm.com>
	<20030723031351.4e9db07c.davem@redhat.com>
	<3F1F0CF7.5020909@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <3F1F0CF7.5020909@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 15:32:23 -0700
Krishna Kumar <krkumar@us.ibm.com> wrote:

> > 1) Remove "void *sysctl;" from ipv6_devconf, move it into
> >    inet6_dev ie. "void *cnf_sysctl;" update all code users.
> 
> There is one problem with this that I am not able to figure out, perhaps I am
> overlooking it. addrconf_sysctl_register() gets called for ipv6_devconf_dflt,
> but there is no inet6_dev for this configuration, so is it possible to move the
> sysctl up (there is no 'up' :-). I don't want to create a dummy inet6_dev for
> this. One way is to embed the actual config structure as follows :

Another idea is to define the user structure:

struct ipv6_user_devconf {
	__u32 forwarding;
...
};

Then:

struct ipv6_kernel_devconf {
	struct ipv6_user_devconf vals;
	void *sysctl;
};

It is similar to what you suggest.

> > 2) Move "struct ipv6_devconf" into some linux/*.h ipv6 header
> >    usable by users.  Use an existing one if possible.  Then
> >    make sure net/if_inet6.h includes this thing.
> 
> The only two ipv6 specific files in linux are ipv6.h and
> ipv6_route.h, neither are appropriate for sysctl stuff I think. So
> should I create a new file like the one for ipv4_devconf exists in
> inetdevice.h ?

I see no reason why ipv6.h is a bad place, heck we have
an in6_ifreq there already.

> > 3) Change "int" members of struct "ipv6_devconf" to "s32".
> 
> All members (except use_tempaddr) seem to be >=0, should I change
> the definition to __u32 instead ?

__u32 sounds fine.
