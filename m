From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Mon, 26 Jun 2006 11:32:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606261116290.21114@d.namei>
References: <20060621200031.589235000@flek.zko.hp.com>
 <20060622.021223.125894633.davem@davemloft.net>  <1151088481.2669.25.camel@localhost.localdomain>
  <20060623.131512.21593290.davem@davemloft.net> <1151094857.2669.51.camel@localhost.localdomain>
 <Pine.LNX.4.64.0606231906380.6209@d.namei> <449C7D2E.8000101@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ted <txtoth@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:18403 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932171AbWFZPcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 11:32:08 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <449C7D2E.8000101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Jun 2006, Paul Moore wrote:

> James Morris wrote:
> > 
> > Support for interoperability with legacy CIPSO systems is something that I 
> > think would be nice to have, if it can be done in a way which doesn't 
> > impact deeply on core kernel code, and plays nicely with native Linux 
> > infrastructure.
> > 
> 
> I'm not sure if you have had a chance to look at the new patch set yet
> but I know you have seen earlier versions and are at least familiar with
> the approach I am taking ... in your opinion is the NetLabel patch
> acceptable in its approach?

The approach basically seems ok, although the priority needs to be on 
getting the native xfrm labeling stuff implemented correctly first before 
really thinking about adding support for legacy schemes.

Here's a possible architectural strategy for all of this:


1. Generic xfrm labeling

2. General MLS infrastructure

3. MLS enhanchements to xfrm labeling

4. CIPSO/RIPSO infrastructure

5. HP and PitBull CIPSO implementations


We have (1) and TCS are working on (3).

(2) would include various intra-kernel and userland API support for any 
common MLS requirements across MLS xfrm labeling and CIPSO schemes.  Also, 
I'm not sure how network namespaces might or might not play into this.

There's also the question of if/how secmark labeling might be used in 
conjunction with these distributed labeling schemes.

Also, the unresolved issue of whether to support CIPSO at all.

Even if the approach is technically acceptable, there's the issue of 
maintaining a lot of complicated code in mainline for a very narrow 
userbase to talk to near-obsolete legacy systems.


- James
-- 
James Morris
<jmorris@namei.org>
