From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] glibc: Terminate process on invalid netlink response from
 kernel [BZ #12926]
Date: Thu, 05 Nov 2015 15:36:54 +0100
Message-ID: <1446734214.3461783.430027857.36EF414F@webmail.messagingengine.com>
References: <562A9391.1040806@redhat.com>
 <1446558492.1880442.427793993.78B20B4F@webmail.messagingengine.com>
 <5638BDE3.2040608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hannes Sowa <hannes@redhat.com>, netdev@vger.kernel.org
To: Florian Weimer <fweimer@redhat.com>,
 GNU C Library <libc-alpha@sourceware.org>, davem@davemloft.net
Return-path: <libc-alpha-return-64746-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <5638BDE3.2040608@redhat.com>
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Nov 3, 2015, at 15:00, Florian Weimer wrote:
> On 11/03/2015 02:48 PM, Hannes Frederic Sowa wrote:
> > Hello,
> > 
> > On Fri, Oct 23, 2015, at 21:07, Florian Weimer wrote:
> >> (By the way, we'd also love to have a better kernel interface to fulfill
> >> the needs for getaddrinfo address sorting.  The netlink requests we
> >> currently use are much too slow if the host has many addresses
> >> configured.)
> > 
> > One solution would be to finish the IPv6 ioctl interface to list
> > addresses. The ioctl interface would need less memory allocations and is
> > a synchronous interface which would make it much more easier for glibc
> > to deal with. No timeouts and retries like with netlink are necessary.
> 
> The more fundamental question is whether we actually have to copy all
> the addresses to userspace.  In the end, it may be better to hand a list
> of destination addresses to the kernel and have it sort them according
> to some algorithm.  But for the algorithm proposed in RFC 6724 section
> 6, this may be not worth the effort because there are so many
> configurable bits.

I would rather not provide a holistic sort function in the kernel for
both IPv4 and IPv6 which would a requirement by glibc, no?

> I still think most of the address sorting is bogus because it appears to
> make guarantees which can break after renumbering.

Yes, of course.

Your patch for glibc looks fine to me, so

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Bye,
Hannes
