From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Fri, 15 Apr 2016 08:54:26 -0700
Message-ID: <57110EB2.5050408@schaufler-ca.com>
References: <cover.1459934322.git.pabeni@redhat.com>
 <CAHC9VhSZP1QxT-pQeHAW9m1xmyDsbFeA=9b8SdeWgS0RiDTOBA@mail.gmail.com>
 <20160406234532.GA731@breakpoint.cc> <2239567.jkCk1gtQAE@sifl>
 <1460451162.5965.16.camel@redhat.com>
 <CAHC9VhSgWAoWgywOZOvT76jCcHuEywjFu5CKJo9D0k+66RbFCA@mail.gmail.com>
 <1460713133.7410.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paolo Abeni <pabeni@redhat.com>, Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm47-vm1.bullet.mail.bf1.yahoo.com ([216.109.115.124]:49629
	"EHLO nm47-vm1.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752018AbcDOQBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 12:01:31 -0400
In-Reply-To: <1460713133.7410.2.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/2016 2:38 AM, Paolo Abeni wrote:
> On Thu, 2016-04-14 at 18:53 -0400, Paul Moore wrote:
>> On Tue, Apr 12, 2016 at 4:52 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>> Will be ok if we post a v2 version of this series, removing the hooks
>>> de-registration bits, but preserving the selinux nf-hooks and
>>> socket_sock_rcv_skb() on-demand/delayed registration ? Will that fit
>>> with the post-init read only memory usage that you are planning ?
>> The work Florian and and I were talking about would be limited just to
>> the netfilter hooks, the LSM hooks, e.g. socket_sock_rcv_skb() and
>> friends, would remain as they are today.  What what we discussing was
>> defaulting to not registering the netfilter hooks until it became
>> necessary due to a labeled networking configuration or the
>> always_check_network policy capability; the registration of the
>> netfilter hooks would be permanent, you could not unregister the hooks
>> at that point, you would need to reboot.  Does that make sense?
> Yes, AFAIC it makes sense. I'll try to follow this route for an eventual
> v2.
>
>> As far as Casey's concerns, I don't think the work we are talking
>> about for the v2 patchset would have any effect on the socket/sock
>> security blobs as you really can't manage those adequately from the
>> netfilter hooks; you most likely will reference them and perhaps even
>> update the data within, but not allocate or free the blobs.  Besides,
>> even in some weird case you were alloc/free'ing security blobs in the
>> netfilter hooks, we can deal with that on a per-LSM basis if/when the
>> full fledged stacking patches are merged; everything we are talking
>> about is a hidden implementation detail so changing it in the future
>> shouldn't be a problem.
> Casey, are you ok with the above?

Yes. My concern is with the security module hooks. Altering
the netfilter hooks is a separate issue, and I don't have
trouble with that.

I also would not expect to see an LSM doing blob allocation
during socket delivery, but hey, it *is* networking code,
and stranger things happen all the time.

> Thank you,
>
> Paolo
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
