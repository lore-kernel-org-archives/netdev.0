From: Djalal Harouni <tixxdz@opendz.org>
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Sat, 31 Mar 2012 15:29:49 +0100
Message-ID: <20120331142949.GD29626@dztty>
References: <20120326222359.GB28123@dztty>
 <20120326.182411.41401140080225401.davem@davemloft.net>
 <20120328163219.GA19778@home.goodmis.org>
 <20120328.165132.1309449708287640005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, ebiederm@xmission.com,
	viro@zeniv.linux.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from numidia.opendz.org ([98.142.220.152]:60036 "EHLO
	numidia.opendz.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757449Ab2CaO0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 10:26:08 -0400
Content-Disposition: inline
In-Reply-To: <20120328.165132.1309449708287640005.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 28, 2012 at 04:51:32PM -0400, David Miller wrote:
> From: Steven Rostedt <rostedt@goodmis.org>
> Date: Wed, 28 Mar 2012 12:32:20 -0400
> 
> > I just started using kmemleak and notice that it reports false positives
> > for several __init functions that call register_sysctl_paths(). The fix
> > you want is:
> > 
> > {
> > 	sturct ctl_table_header *head;
> > 
> > 	head = register_sysctl_paths(ipv4_path, ipv4_skeleton);
> > 	BUG_ON(!head);
> > 	kmemleak_ignore(head);
> > 
> > 
> > No need to waste a pointer just to keep the reference around for
> > kmemleak.
Thanks Steven, yes it's a nice solution for false positive ones.

> That looks a lot saner than the other suggestions, indeed.
Yes, however now I'm not sure that these are real false positive ones,
please check my other email, and someone who knows the code should take a
closer look.

Thank.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
tixxdz
http://opendz.org
