From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 8/9] ipvlan: improve compiler hints
Date: Thu, 27 Apr 2017 15:27:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE070F@AcuExch.aculab.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
 <20170427145142.15830-9-marco.chiappero@intel.com>
 <B1C1DF2ACD01FD4881736AA51731BAB2B2EFB2@ORSMSX107.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S . Miller" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Grandhi, Sainath" <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>
To: "'Duyck, Alexander H'" <alexander.h.duyck@intel.com>,
        "Chiappero, Marco" <marco.chiappero@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:63952 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936346AbdD0P1Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 11:27:24 -0400
In-Reply-To: <B1C1DF2ACD01FD4881736AA51731BAB2B2EFB2@ORSMSX107.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duyck, Alexander H
> Sent: 27 April 2017 16:21
...
> > -unsigned int ipvlan_mac_hash(const unsigned char *addr)
> > +inline unsigned int ipvlan_mac_hash(const unsigned char *addr)
> >  {
> >  	u32 hash = jhash_1word(__get_unaligned_cpu32(addr + 2),
> >  			       ipvlan_jhash_secret);
> 
> I'm kind of surprised this isn't causing a problem with differing declarations between the declaration
> here and the declaration in ipvlan.h. Normally for inlining something like this you would change it to
> a "static inline" and move the entire declaration into the header file.

You get a callable copy for external callers and local calls inlined.
Not usually what you want.

	David
