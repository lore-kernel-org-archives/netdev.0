From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Thu, 7 Aug 2003 13:05:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807130502.4af9c815.davem@redhat.com>
References: <200307141045.40999.nf@hipac.org>
	<1058328537.1797.24.camel@jzny.localdomain>
	<3F16A0E5.1080007@hipac.org>
	<1059934468.1103.41.camel@jzny.localdomain>
	<3F2E5CD6.4030500@hipac.org>
	<1060012260.1103.380.camel@jzny.localdomain>
	<3F302E04.1090503@hipac.org>
	<1060286331.1025.73.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nf@hipac.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060286331.1025.73.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07 Aug 2003 15:58:51 -0400
jamal <hadi@cyberus.ca> wrote:

> > Yes, it does. Still the question is how to solve this
> > generally. Consider the following example ruleset:
> > 
> > 1) src ip 10.0.0.0/30 dst ip 20.0.0.0/20
> > 2) src ip 10.0.0.0/28 dst ip 20.0.0.0/22
> > 3) src ip 10.0.0.0/26 dst ip 20.0.0.0/24
> > 4) src ip 10.0.0.0/24 dst ip 20.0.0.0/26
> > 5) src ip 10.0.0.0/22 dst ip 20.0.0.0/28
> > 6) src ip 10.0.0.0/20 dst ip 20.0.0.0/30
> > 
> > So you have 1 src ip hash and #buckets(src ip hash) many
> > dst ip hashes. In order to achieve maximum performance
> > you have to minimize the number of collisions in the
> > hash buckets. How would you choose the hash function
> > and what would the construction look like?
> > 
> 
> It can be done by using the masks - but it would look really ugly. I
> suppose just providing a good user interface is valuable.

If you input all the keys into the Jenkins hash, how does
it perform?  Has anyone even tried that and compared it
to all of these fancy multi-level tree like hash things?

I think Jenkins would work very well for exactly this kind
of application.  And it's fully available to the entire kernel
via linux/jhash.h and already in use by other things such
as the routing cache and the netfilter conntrack code.
