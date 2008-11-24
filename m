From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] lro: ip fragment checking
Date: Mon, 24 Nov 2008 16:51:08 +0000
Message-ID: <1227545468.3162.4.camel@achroite>
References: <492ACEC4.3020702@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tklein@de.ibm.com, Christoph Raisch <raisch@de.ibm.com>,
	jb.billaud@gmail.com, hering2@de.ibm.com
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34013 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753108AbYKXQvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:51:14 -0500
In-Reply-To: <492ACEC4.3020702@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-24 at 16:56 +0100, Jan-Bernd Themann wrote:
> Currently there is no checking in the LRO receive path whether
> TCP packets are ip fragmented. We should not consider
> those packets for aggregation.
> I'm not sure if this checking is actually required. Does anyone
> know if it is possible to get fragmented TCP packets without
> the tcp stack changing the MSS size?
> This patch introduces explicit checking. Any objections?

LRO depends on the hardware performing TCP checksum offload, and the TCP
checksum cannot be verified for IP fragments in isolation.  So I think
drivers should not be passing fragments into inet_lro or should reject
them in its get_frag_header() or get_skb_header() method.  Certainly sfc
doesn't pass fragments into inet_lro because they have not been
checksummed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

