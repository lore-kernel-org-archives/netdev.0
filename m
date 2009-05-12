From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Bridge] [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Tue, 12 May 2009 20:24:32 +0400
Message-ID: <20090512162432.GA12820@lenovo>
References: <20090511114639.440944109@openvz.org> <de7adc5e0905112230r60254113t6b31d8114d141be@mail.gmail.com> <aa79d98a0905112319k6bc19ebk60a6458165b8c0a1@mail.gmail.com> <de7adc5e0905120002o7f19a1eepe0397d698c08ce97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, xemul@openvz.org
To: Daniel Robbins <drobbins@funtoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:33037 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbZELQYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 12:24:34 -0400
Received: by bwz22 with SMTP id 22so74675bwz.37
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 09:24:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <de7adc5e0905120002o7f19a1eepe0397d698c08ce97@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Daniel Robbins - Tue, May 12, 2009 at 01:02:01AM -0600]
|
| Is this functionality useful for OpenVZ? Do people need the ability to
| do this? Why/when is it necessary for me to be able to add eth0 to a
| bridge remotely?
| 

As far as I know (fix me if I'm wrong) you're not able to configure
bridge remotely from the scratch via active port (say eth0) without
interrupting the session and recreating routing table. Of course you
could have a script which will do all work for you. (or you could
be having a machine with 3/4/5/10 NIC's and one of them could be
just reserved to be used remote access only with proper routing
table, etc...). But in case if all nics are to be used as bridge
ports and you still need to access such a machine remotely i believe
via_phys_dev could be our friend :)

So, Daniel, i think the right question is -- do I ever need to
configure/setup bridge remotely? I suppose yes, it happens.
(at least I had a machine with lack of input device except a few
 NICs :-)

|
| I don't quite (yet) understand the usefulness of this feature. You
| would still be very limited in what you can change with the network if
| you are remote, right? That's why I don't quite understand the benefit
| of this feature. How are you planning to use it? When I set up my
| OpenVZ systems, I like to get the overall network/bridge configuration
| perfect so that I don't need to make major changes when I am remote.
|

This feature already was in OpenVZ 2.6.24 kernel. I'm more intiresting in
usefulness of this feature for the mainline. (in short -- we use it for bridging
VEs with eth0 as a master device so all works without needing to
reconfigure routing table). Moreover, since bridge already support
namespacing the feature could be usefull for lxc as well (though
didn't check to be fair).

| 
| Again, I am not an expert so I am asking purely for my own curiosity.
| I support the idea of making networking more flexible, but I do not
| see this particular step addressed by the patch as a common need. That
| may be due to my own lack of understanding.
| 

That is why it's RFC so people could decide should it be included
into mainline or not. Worth it so or not.

|
| I am a big fan of OpenVZ though, so if it helps OpenVZ in some way,
| I'd like to know about it :)
|

Yes it helps to bridge VE's without reconstructing routing table
on HW node.

| 
| -Daniel
| 
 
	-- Cyrill
