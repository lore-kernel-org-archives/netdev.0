From: Paul Moore <paul.moore@hp.com>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Fri, 2 Feb 2007 10:30:28 -0500
Message-ID: <200702021030.28680.paul.moore@hp.com>
References: <1170370281.2603.359.camel@faith.austin.ibm.com> <Pine.LNX.4.64.0702011819070.11820@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyekkirala@trustedcs.com,
	herbert@gondor.apana.org.au, davem@davemloft.net
To: James Morris <jmorris@namei.org>,
	Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:56088 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161141AbXBBPab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 10:30:31 -0500
In-Reply-To: <Pine.LNX.4.64.0702011819070.11820@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, February 1 2007 6:44 pm, James Morris wrote:
> On Thu, 1 Feb 2007, Joy Latten wrote:
> > When using labeled xfrms (xfrms that contain a security context), there
> > is potential for a greater amount of SAs to be created than when using
> > regular xfrms. An SA may be created every time a different security
> > context is encountered in a particular traffic stream. This could be
> > many if each networking app has its own security context, making current
> > behavior problematic.
>
> Do you have any examples of how many SAs would need to be created on a
> typical system?
>
> It may not be the end of the world if an MLS box has to negotiate a
> whole bunch of SAs when it boots up.

I agree that having an MLS box spend some extra time when starting the IKE 
daemon is probably not the end of the world.  However, I'm a little concerned 
that it may not be possible to determine a "good" set of SAs to negotiate 
with only the SPD as a reference.

For example, the current SELinux MLS policy has 16 sensitivity levels and 1024 
categories.  Ignoring the TE portion of the SELinux context for the sake of 
clarity you can easily see the large number of unique combinations, with each 
combination requiring a new SA.  Granted, in the majority of these cases only 
a quick mode IKE negotiation would be required, which is much less expensive 
then having to do a full phase-1 negotiation, but due to the large numbers of 
SAs involved I believe it would still be quite a task.  It also should be 
said that this procedure would need to be done for each SPD rule.

I haven't thought about this too much yet, but I suspect proactively creating 
SAs is not going to be a practical solution.

-- 
paul moore
linux security @ hp
