From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 19:39:58 -0700
Message-ID: <20080828023958.GB21395@juhlenko-desk.sanmateo.corp.akamai.com>
References: <48B46B48.7030609@cosmosbay.com> <20080826205158.GA15266@2ka.mipt.ru> <87vdxmr53f.fsf@basil.nowhere.org> <20080827.143401.76242975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, johnpol@2ka.mipt.ru, dada1@cosmosbay.com,
	denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay01.akamai.com ([72.246.2.12]:39019 "EHLO
	prod-mail-xrelay01.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753633AbYH1CpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 22:45:03 -0400
Content-Disposition: inline
In-Reply-To: <20080827.143401.76242975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 14:34:01 -0700, David Miller wrote:
> By the time you get to the socket, it might be eons (relatively
> speaking) later, decreasing the usefulness of the timestamp.

It's a *socket* option.  It's named SO_TIMESTAMP.  Users of it ought
to *expect* that it records the time the packet hits the socket, not
the time the frame hits the device.

If banks want to know when frames are hitting their devices, that's
fine, but setsockopt() is the wrong layer for controlling that sort of
thing.  An interface flag would make a lot more sense.


> I find it amusing that nobody it talking about fixing the tools
> that are creating the timestamp requests when they have no real
> reason for having them in the first place.

I don't agree that the tools are broken.  Some of them may have
frivolous reasons for wanting timestamps, but they're asking for
something at the socket layer, with the scope of a single socket, and
it's hardly their fault that we respond to that by doing something
expensive and global at a much lower level.
