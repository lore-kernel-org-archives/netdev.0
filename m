From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: switching network namespace midway
Date: Fri, 2 Nov 2012 10:03:53 -0400
Message-ID: <20121102140353.GE18091@kvack.org>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com> <878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org> <CAFaHj6Ey4vzXskvsKB_dG4fKGsn4X5oCF3N0YpGskiSaXrGSOw@mail.gmail.com> <20121025155927.GI15034@kvack.org> <87a9var0ih.fsf@xmission.com> <20121102022542.GD18091@kvack.org> <87k3u4il2l.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rsa <ravi.mlists@gmail.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:45135 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762804Ab2KBODy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 10:03:54 -0400
Content-Disposition: inline
In-Reply-To: <87k3u4il2l.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 01, 2012 at 11:18:58PM -0700, Eric W. Biederman wrote:
> You need a per network namespace exit function to delete the tunnel when
> the xmit direction goes away.  Otherwise we have a very nasty race if
> the original network namespace exits.

That already exists as ipgre_exit_net().  Since the ip_tunnel structure 
remains hashed in the network namespace that creation occurred in, this 
case should be covered.

> NETNS_LOCAL may make sense on the reference device that is used to
> support ioctls for creating devices.

*nod*  That makes sense.

> ipgre_open ?  It looks like it needs to be handled.  Probably that
> ip_route_output_gre needs to be moved.

Good catch.  Will respin with that changed.

> ipv6?

That's next on the list.  There are also issues with ipip, ipmr and 
ipvti, as well as their ipv6 versions.

		-ben
-- 
"Thought is the essence of where you are now."
