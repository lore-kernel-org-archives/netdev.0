From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Thu, 20 Mar 2014 12:02:11 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C8968A5@CMEXMB1.ad.emulex.com>
References: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
 <20140319.155930.1805664690676428310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ben Hutchings (ben@decadent.org.uk)" <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:15032 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaCTMCN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 08:02:13 -0400
In-Reply-To: <20140319.155930.1805664690676428310.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > NIC drivers that support RSS use either a hard-coded value or a random
> > value for the RSS hash key. Irrespective of the type of the key used,
> > the user would want to change the hash key if he/she is not satisfied
> > with the effectiveness of the default hash-key in spreading the incoming flows
> evenly across the RSS queues.
> >
> > This patch set adds support for configuring the RSS hash-key via the
> > ethtool interface using -X option.
> 
> I apologize, but I really dislike this.  For several reasons.
> 
> First, why aren't we adding _just_ a RSS hash changing interface?
> 
> We already have an interface for changing the indirection table, there is
> absolutely not need to add a second interface that supports both indirection
> table _plus_ hash modifications.
> 
> And combining these two is what leads to this hard to audit, ugly, data structure
> layout.
> 
> There's the indirection table at some offset, then the key at some other offset.
> This makes it impossible to impose type checking of any kind on both objects.
> 
> And the data structure is furthermore named in a way that suggests it's just for
> doing things with the RSS hash.
> 
> Just add:
> 
> struct ethtool_rxfh {
> 	__u32	cmd;
> 	__u32	key_size;
> 	__u32	key[0];
> };
> 
> And that's it.
> 
> To change the indirection table, call "ETHTOOL_SRXFH".  To set the RSS flow
> hash, call "ETHTOOL_SRSSH".

My original patch was exactly the way you suggested.
It went through many changes later with the intention of combining both indirection and hash key setting into one option as both are related to rss configuration.
