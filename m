From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Wed, 1 Oct 2003 06:14:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001061426.0b67a235.davem@redhat.com>
References: <20031001054226.126cea7b.davem@redhat.com>
	<200310011307.h91D7jkT004153@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
In-Reply-To: <200310011307.h91D7jkT004153@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 01 Oct 2003 09:07:45 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> i had initially written it that way but remembered at one point i
> was going to use the rtnl semaphore to handle this problem.  any
> opinions on what is 'better'?

Blocking all network configuration operations (even ones not
for your subsystem) is a little bit anti-social in SMP cases.

If you take the rwlock as a reader, you only interfere with a
very minute class of network configuration code paths (those that
need to take the rwlock in question as a writer).

For example, if you use the rwlock-as-reader approach, someone doing
IPV4 routing table updates (ie. routing daemon changing a couple
thousand routes after a BGP flap) won't be perturbed while the ATM
operation is in progress.
