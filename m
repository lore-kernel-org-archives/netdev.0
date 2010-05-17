From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] rtnetlink: make SR-IOV VF interface symmetric
Date: Mon, 17 May 2010 09:10:43 -0700
Message-ID: <20100517161043.GB8301@sequoia.sous-sol.org>
References: <20100515031416.GE15313@sequoia.sous-sol.org>
 <201005151104.41158.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, davem@davemloft.net,
	kaber@trash.net, mitch.a.williams@intel.com, scofeldm@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:41297 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752394Ab0EQQK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 12:10:56 -0400
Content-Disposition: inline
In-Reply-To: <201005151104.41158.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann (arnd@arndb.de) wrote:
> On Saturday 15 May 2010 05:14:16 Chris Wright wrote:
> > Now we have a set of nested attributes:
> > 
> >   IFLA_VFINFO_LIST (NESTED)
> >     IFLA_VF_INFO (NESTED)
> >       IFLA_VF_MAC
> >       IFLA_VF_VLAN
> >       IFLA_VF_TX_RATE
> > 
> > This allows a single set to operate on multiple attributes if desired.
> > Among other things, it means a dump can be replayed to set state.
> > 
> > The current interface has yet to be released, so this seems like
> > something to consider for 2.6.34.
> > 
> > Signed-off-by: Chris Wright <chrisw@sous-sol.org
> 
> Very nice! This would be the minimum change to make the ABI conform
> to the general rules, so it would be really good to have that.
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> 
> It does make the interface a bit strange (less than before), since the
> new IFLA_VF_INFO now contains three nested attributes that each contain their
> own vf number field, and we don't require that they are identical or that
> each of the nested attributes inside VF_INFO appears only once.
> 
> How about a second patch that splits out an IFLA_VF_NUMBER attribute
> and makes do_setvfinfo use nla_parse_nested instead of nla_for_each_nested
> in order to tighten the rules on this some more?

Yes, that's a great idea Arnd.  I'll tighten that up.

thanks,
-chris
