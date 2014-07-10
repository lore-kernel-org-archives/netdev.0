From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 0/5] SCTP updates
Date: Thu, 10 Jul 2014 06:55:52 -0400
Message-ID: <20140710105552.GA4437@hmsreliant.think-freely.org>
References: <20140708144127.GB23026@hmsreliant.think-freely.org>
 <53BD1211.4080504@redhat.com>
 <20140709104958.GA3784@hmsreliant.think-freely.org>
 <53BD4363.70306@redhat.com>
 <20140709151354.GA5250@localhost.localdomain>
 <53BD6167.1030000@gmail.com>
 <20140709154428.GD5250@localhost.localdomain>
 <53BD6EB7.7070302@gmail.com>
 <20140709183508.GB14509@hmsreliant.think-freely.org>
 <063D6719AE5E284EB5DD2968C1650D6D1726FBA0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"geirola@gmail.com" <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37047 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaGJK4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 06:56:05 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726FBA0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 09:02:23AM +0000, David Laight wrote:
> From: Neil Horman
> ...
> > > No there is not direct overlap between the two.  However, as Michael pointed out,
> > > there is a new option to control SCTP_RCVINFO.  So would could add a deprecation
> > > warning to the over SCTP_EVENTS option and carry SCTP_SNDRCVINFO with it.
> > > Once SCTP_EVENTS goes away so can SCTP_SNDRCVINFO.
> > >
> > Ok, so we should still consider deprecation warnings then.  Daniel, what about
> > ratelimited warnings with pids included then?
> 
> Can you defer any deprecation warnings for a few kernel versions?
> This gives time for applications to be recoded.
I'm not sure I understand the reasoning here?  Why should a deprecation warning
be delayed so you can recode your application?  What about all the people who
aren't subscribed this list?  That just furhter delays their finding out about
the deprecation.

> Including argv[0] (even just the exec-time value) is much more use than the pid.
> 
Thats fine, I think deprecation warnings usually have the form "[deprecated] pid
%d(%s)..." where %s is argv[0].

> Actually this is 'right PITA' for an application.
> A program binary that needs to work with old and new kernels will have to
> try the new option, and if it fails fall back to the old one, and then
> conditionally create/inspect the cmsg data.
> I can't actually imagine anyone bothering!
> 
A deprecation warning is just that, a warning, it doesn't cause the old
method to fail, its just a heads up to the application developer that they need
to make a change sometime in the next 5 years.  If you implement the new method
in your application, you can wait for a reasonable period of time until you are
confident that you application isn't being used on older kernels, or bump the
minimal kernel version to run your app, and cut over to the new method.

> Our sctp code is actually in a kernel module, so we can look at the kernel
> version when (part of) the driver is compiled on the target system.
> 
You can do that too if you would like.
Neil

> 	David
> 
> 
> 
> 
