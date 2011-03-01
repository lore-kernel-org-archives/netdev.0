From: Joe Buehler <aspam@cox.net>
Subject: Re: source route ignored in favor of local interface
Date: Tue, 01 Mar 2011 14:31:58 -0500
Message-ID: <4D6D49AE.2030303@cox.net>
References: <loom.20110301T154947-689@post.gmane.org> <4D6D4370.5040308@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmfepi103.cox.net ([68.230.241.199]:38365 "EHLO
	eastrmfepi103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757179Ab1CATqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 14:46:23 -0500
In-Reply-To: <4D6D4370.5040308@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you really want to modify things, have you looked at your ip rules?
> "ip ru" will dump them.  Typically it looks something like
> 
> 0:      from all lookup local
> 32766:  from all lookup main
> 32767:  from all lookup default
> 
> The last item in each row is the name of the routing table.  As you can
> see, the first rule is for local interfaces, and a later rule deals with
> the main and default routing tables.
> 
> You could move the local lookup to rule 1 and add in a new rule 0
> specifically dealing with your situation.

We have tried some variations on modifications to ip rules, but the
kernel appears to treat rule 0 specially -- it cannot be deleted, for
example.  This results in the enforcing of local interfaces before
source routes -- surely something that should be a policy decision, not
hard-coded.

Let me rephrase and ask: Does anyone know how to replace the priority 0
rule?

Joe Buehler
