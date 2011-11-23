From: jamal <hadi@cyberus.ca>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 23 Nov 2011 07:22:56 -0500
Message-ID: <1322050976.2039.125.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51752 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1KWMXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 07:23:00 -0500
Received: by yenq3 with SMTP id q3so1316307yen.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 04:23:00 -0800 (PST)
In-Reply-To: <20111123075433.GA7928@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-23 at 15:54 +0800, Herbert Xu wrote:

> I mostly agree with Jamal.  As far as the concept of a policy
> lookup cache goes (which appears to be at the core of OVS), this
> almost fits exactly onto a u32 hash table.  All that would be needed
> is to add the tail end of the policies, e.g., with new packet
> actions.

For a classifier, u32 or em matches would do the job  - but they may
need a wrapper around it in user space; so from a usability pov, it
would make sense to have a new classifier that is specific to them.
All the VLAN actions could go into one tc action; the checksum action
is already present. The IP/TCP/UDP header re-writes may require 
their own actions - I think one would be sufficient for all.
So in my estimate one classifier and two actions.
Then you get rid of half the code (they use generic netlink to set/get
policies)

> However, this is purely based on my conceptual view of OVS, which
> may or may not be accurate.  I'll dig into the patches over the
> next couple of days to see if they could be easily turned into
> packet actions or whether this is difficult for reasons that we
> have not yet discovered.
> 

I cant find one - you may. After staring at the code, I am also now
questioning if the existing bridge code couldnt have been re-used with
some small tweaks.
The virtual ports attached to the bridging code may be needed.
A lot of the multi-tenancy intelligence belongs in user space controller
(my reading was that was justification for not re-using bridging code 
as is).

cheers,
jamal
