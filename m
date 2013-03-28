From: Serge Hallyn <serge.hallyn@ubuntu.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Wed, 27 Mar 2013 23:28:08 -0500
Message-ID: <20130328042808.GA11672@sergelap>
References: <CD78B3C3.76D3%blourdel@juniper.net>
 <874nfwri6o.fsf@xmission.com>
 <20130327104746.0ec9dcb5@nehalam.linuxnetplumber.net>
 <87620cpd0y.fsf@xmission.com>
 <20130328032046.GA32083@sergelap>
 <87vc8cnq6v.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35100 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305Ab3C1E2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 00:28:17 -0400
Content-Disposition: inline
In-Reply-To: <87vc8cnq6v.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Serge Hallyn <serge.hallyn@ubuntu.com> writes:
> 
> > Quoting Eric W. Biederman (ebiederm@xmission.com):
> >> Stephen Hemminger <stephen@networkplumber.org> writes:
> >> 
> >> > If you need to do lots of operations the --batch mode will be significantly faster.
> >> > One command start and one link map.
> >> 
> >> The problem in this case as I understand it is lots of independent
> >> operations. Now maybe lxc should not shell out to ip and perform the
> >> work itself.
> >
> > fwiw lxc uses netlink to create new veths, and picks random names with
> > mktemp() ahead of time.
> 
> I am puzzled where does the slownes in iproute2 come into play?

Benoit originally reported slowness when starting >1500 containers.  I
asked him to run a few manual tests to figure out what was taking the
time.  Manually creating a large # of veths was an obvious test, and
one which showed poorly scaling performance.

May well be there are other things slowing down lxc of course.

-serge
