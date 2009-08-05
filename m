From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v1 1/2] lsm: Add hooks to the TUN driver
Date: Wed, 5 Aug 2009 17:58:38 -0400
Message-ID: <200908051758.39051.paul.moore@hp.com>
References: <20090804211304.10798.65601.stgit@flek.lan> <20090804212158.10798.34592.stgit@flek.lan> <20090805141350.GA353@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: "Serge E. Hallyn" <serue@us.ibm.com>, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:4875 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbZHEV6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 17:58:44 -0400
In-Reply-To: <20090805141350.GA353@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 August 2009 10:13:50 am Serge E. Hallyn wrote:
> Quoting Paul Moore (paul.moore@hp.com):

[NOTE: my email has been out all day due to some mysterious FS issue so my 
apologies for not replying sooner]

...

> The checks before and after this patch are not equivalent.  Post-patch,
> one must always have CAP_NET_ADMIN to do the attach, whereas pre-patch
> you only needed those if current_cred() did not own the tun device.  Is
> that intentional?

Nope, just a goof on my part; I misread the booleans and haven't fully tested 
the patch yet so it slipped out, thanks for catching it.  This brings up a 
good point, would we rather move the TUN owner/group checks into the cap_tun_* 
functions or move the capable() call back into the TUN driver?  The answer 
wasn't clear to me when I was looking at the code before and the uniqueness of 
the TUN driver doesn't help much in this regard.

> Also as Eric said this patch needs to set the cap_ hooks.  This patch
> isn't yet introducing the selinux hooks, so iiuc actually this patch should
> always oops if CONFIG_SECURITY=y.

Yep, another symptom of not enough testing as I mentioned out in the original 
posting, thanks to both of you for pointing this out ... now somebody just 
needs to fix Rawhide so I can actually get a KVM instance running :)

-- 
paul moore
linux @ hp

