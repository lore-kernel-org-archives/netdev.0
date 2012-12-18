From: Dan Williams <dcbw@redhat.com>
Subject: Re: network namespace and DNS lookups
Date: Tue, 18 Dec 2012 11:22:59 -0600
Message-ID: <1355851379.30992.12.camel@dcbw.foobar.com>
References: <CAFaHj6GVgDf2QXUWyaKYnvOqLJRjG+kA32eEk5psPkmc-RPY1Q@mail.gmail.com>
	 <CAFaHj6HT0c59us_7F9Uh7BYh_YXGRt30=yLOrV=hcrG29YO-qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ravi Aysola <ravi.mlists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609Ab2LRRVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 12:21:22 -0500
In-Reply-To: <CAFaHj6HT0c59us_7F9Uh7BYh_YXGRt30=yLOrV=hcrG29YO-qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 10:49 -0500, Ravi Aysola wrote:
> I think I sent my earlier email a bit prematurely.  I do have
> /etc/netns/<namespace-name>/resolv.conf
> files under each of my namespaces. Now the question is, how does a
> user space process
> (say bind)  look at a namespace specific resolv.conf instead of
> default one?  Have any of
> these standard applications been modified to work with namespace
> specific config files?

Wouldn't that be the glibc resolver's domain?  DNS lookups aren't done
by the kernel, but by glibc in userspace.  And glibc is also what reads
resolv.conf, so most things DNS-namespace related would need to happen
there.

Dan

> thanks again
> ravi/
> 
> On Tue, Dec 18, 2012 at 10:09 AM, Ravi Aysola <ravi.mlists@gmail.com> wrote:
> > Has there been any work in any of the recent kernels to limit the DNS lookup
> > to a particular network namespace?  Do we have any facility to specify the
> > DNS resolvers on network namespace basis (such as /etc/ns/resolv.conf)?
> >
> > thank you
> > ravi/
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
