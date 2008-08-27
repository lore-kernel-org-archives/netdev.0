From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 09:17:06 -0700
Message-ID: <20080827091706.574f2fae@extreme>
References: <200808220457.40892.denys@visp.net.lb>
	<20080826201406.GA24827@2ka.mipt.ru>
	<48B46B48.7030609@cosmosbay.com>
	<20080826205158.GA15266@2ka.mipt.ru>
	<87vdxmr53f.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36005 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755091AbYH0QRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 12:17:09 -0400
In-Reply-To: <87vdxmr53f.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008 14:54:12 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> >
> > Yup, this innocent toys can end up with this such behaviour on modern
> > highly loaded machines.
> 
> I and also other people had some patches to move the time stamp
> measuring into the socket. This way the time stamping didn't need to
> be enabled on all packets, only on those that actually end up at a
> socket that requires the time stamp.
> 
> Unfortunately DaveM didn't like it because some bank wanted
> different semantics, see the discussion in 
> http://thread.gmane.org/gmane.linux.network/91679
> 
> Perhaps you can find out which bank it was and send them a bill for
> your CPU time ;-)
> 
> -Andi
> 

Look at /proc/net/ptype to see if any AF_PACKET sockets are open.
There are several causes of this:
   * Applications like DHCP use AF_PACKET when they could use something else
   * AF_PACKET API was poorly designed and always has timestamps
   * The choice was made to get more accurate timestamps by stamping early in
     receive code. A better alternative would be to do it in protocol handler
     after the socket filter. Sorry, Andi socket layer is too late.
   * No driver is using hardware mechanisms to get accurate/free timestamps.
     I was working on sky2, but never was stable/complete.

Easist advice now is to fix userspace.
