From: Solar Designer <solar@openwall.com>
Subject: Re: [RFC] ipv4: add ICMP socket kind
Date: Tue, 21 Dec 2010 22:46:06 +0300
Message-ID: <20101221194606.GA25359@openwall.com>
References: <20101221181800.GA8166@albatros> <AANLkTikS6rs-AFGmtTfuRdELJ5+y=o4g1i0Xk9KDFRiv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vasiliy Kulikov <segooon@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>
To: Colin Walters <walters@verbum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikS6rs-AFGmtTfuRdELJ5+y=o4g1i0Xk9KDFRiv@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 21, 2010 at 01:46:41PM -0500, Colin Walters wrote:
> On Tue, Dec 21, 2010 at 1:18 PM, Vasiliy Kulikov <segooon@gmail.com> wrote:
> > A new ping socket is created with
> >
> >  socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)
> 
> And the default is to allow any uid to do this (modulo LSM)?

We intend to have this sysctl'able and to have it restricted to a group
by default (the sysctl would set the GID) on our Linux distro,
Openwall GNU/*/Linux.  However, we figured that it'd be tough for us to
get this complication accepted into mainstream, so we opted to have the
patch posted for comment without it.

> If you really have a burning desire to get rid of setuid /bin/ping,
> why not just do it in userspace via message passing to/from a
> privileged process, and avoid a lot of code in the kernel?

Yes, we thought of that, and we don't like this solution.  We similarly
(but for different reasons) don't like using fscaps to grant CAP_NET_RAW
to ping.

We share your concern about the size of net/ipv4/ping.c introduced by
this patch, yet this is our current proposal.

> It's much
> more flexible.  You could, for example, limit it to once a second by
> default, allow only one process doing this per uid, etc.

We figured that there's little point behind such restrictions.  Just how
is an ICMP echo request any worse than a UDP packet of the same size?
Anyone can send the latter with current kernels.

Additionally, Vasiliy found out that Mac OS X has a similar feature,
implemented in a riskier way than what we propose (they do no filtering
of incoming ICMP traffic):

http://www.manpagez.com/man/4/icmp/

So there's precedent, and our proposal is better.

Yet, as I have mentioned, we're in fact going to restrict this to a
group by default and to have ping SGID - just not to expose the extra
kernel code for direct attack by a local user.  That's in case there's a
vulnerability in the added code.

If a sysctl like this is what others want to have as well, we'd be happy
to provide a revision of the patch including that.  Then we won't have
to maintain it as a custom patch.

Thank you for your criticism.

Alexander Peslyak <solar at openwall.com>
GPG key ID: 5B341F15  fp: B3FB 63F4 D7A3 BCCC 6F6E  FC55 A2FC 027C 5B34 1F15
http://www.openwall.com - bringing security into open computing environments
