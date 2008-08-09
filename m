From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH] netlabel: Replace protocol/NetLabel linking with refrerence counts
Date: Sat, 9 Aug 2008 15:42:28 -0400
Message-ID: <200808091542.28776.paul.moore@hp.com>
References: <20080809144322.11314.76039.stgit@flek.lan> <20080809170840.GF8125@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:4602 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbYHITnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 15:43:03 -0400
In-Reply-To: <20080809170840.GF8125@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 August 2008 1:08:40 pm Paul E. McKenney wrote:
> On Sat, Aug 09, 2008 at 10:43:22AM -0400, Paul Moore wrote:
> > NetLabel has always had a list of backpointers in the CIPSO DOI
> > definition structure which pointed to the NetLabel LSM domain
> > mapping structures which referenced the CIPSO DOI struct.  The
> > rationale for this was that when an administrator removed a CIPSO
> > DOI from the system all of the associated NetLabel LSM domain
> > mappings should be removed as well; a list of backpointers made
> > this a simple operation.
> >
> > Unfortunately, while the backpointers did make the removal easier
> > they were a bit of a mess from an implementation point of view
> > which was making further development difficult.  Since the removal
> > of a CIPSO DOI is a realtively rare event it seems to make sense to
> > remove this backpointer list as the optimization was hurting us
> > more then it was helping.  However, we still need to be able to
> > track when a CIPSO DOI definition is being used so replace the
> > backpointer list with a reference count.  In order to preserve the
> > current functionality of removing the associated LSM domain
> > mappings when a CIPSO DOI is removed we walk the LSM domain mapping
> > table, removing the relevant entries.
>
> Looks good from an RCU viewpoint!

Great, thanks for all your help :)

-- 
paul moore
linux @ hp
