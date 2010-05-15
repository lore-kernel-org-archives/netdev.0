From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] rtnetlink: make SR-IOV VF interface symmetric
Date: Sat, 15 May 2010 11:04:40 +0200
Message-ID: <201005151104.41158.arnd@arndb.de>
References: <20100515031416.GE15313@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, mitch.a.williams@intel.com,
	scofeldm@cisco.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61829 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870Ab0EOJFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 May 2010 05:05:00 -0400
In-Reply-To: <20100515031416.GE15313@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 15 May 2010 05:14:16 Chris Wright wrote:
> Now we have a set of nested attributes:
> 
>   IFLA_VFINFO_LIST (NESTED)
>     IFLA_VF_INFO (NESTED)
>       IFLA_VF_MAC
>       IFLA_VF_VLAN
>       IFLA_VF_TX_RATE
> 
> This allows a single set to operate on multiple attributes if desired.
> Among other things, it means a dump can be replayed to set state.
> 
> The current interface has yet to be released, so this seems like
> something to consider for 2.6.34.
> 
> Signed-off-by: Chris Wright <chrisw@sous-sol.org

Very nice! This would be the minimum change to make the ABI conform
to the general rules, so it would be really good to have that.

Acked-by: Arnd Bergmann <arnd@arndb.de>

It does make the interface a bit strange (less than before), since the
new IFLA_VF_INFO now contains three nested attributes that each contain their
own vf number field, and we don't require that they are identical or that
each of the nested attributes inside VF_INFO appears only once.

How about a second patch that splits out an IFLA_VF_NUMBER attribute
and makes do_setvfinfo use nla_parse_nested instead of nla_for_each_nested
in order to tighten the rules on this some more?

	Arnd
