From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Wed, 20 Feb 2008 10:14:02 -0800
Message-ID: <1203531242.15017.20.camel@nimitz.home.sr71.net>
References: <200802111724.12416.ossthema@de.ibm.com>
	 <OF58A8E0B3.B5CC265E-ONC12573F0.00496E2B-C12573F0.0049850F@de.ibm.com>
	 <1203094538.8142.23.camel@nimitz.home.sr71.net>
	 <200802181100.12995.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Christoph Raisch <RAISCH@de.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>,
	ossthema@linux.vnet.ibm.com,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Greg KH <greg@kroah.com>, apw <apw@uk.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	netdev <netdev@vger.kernel.org>, tklein@linux.ibm.com
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:35771 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbYBTSOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 13:14:14 -0500
In-Reply-To: <200802181100.12995.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-18 at 11:00 +0100, Jan-Bernd Themann wrote:
> Dave Hansen <haveblue@us.ibm.com> wrote on 15.02.2008 17:55:38:
> 
> > I've been thinking about that, and I don't think you really *need* to
> > keep a comprehensive map like that. 
> > 
> > When the memory is in a particular configuration (range of memory
> > present along with unique set of holes) you get a unique ehea_bmap
> > configuration.  That layout is completely predictable.
> > 
> > So, if at any time you want to figure out what the ehea_bmap address for
> > a particular *Linux* virtual address is, you just need to pretend that
> > you're creating the entire ehea_bmap, use the same algorithm and figure
> > out host you would have placed things, and use that result.
> > 
> > Now, that's going to be a slow, crappy linear search (but maybe not as
> > slow as recreating the silly thing).  So, you might eventually run into
> > some scalability problems with a lot of packets going around.  But, I'd
> > be curious if you do in practice.
> 
> Up to 14 addresses translation per packet (sg_list) might be required on 
> the transmit side. On receive side it is only 1. Most packets require only 
> very few translations (1 or sometimes more)  translations. However, 
> with more then 700.000 packets per second this approach does not seem 
> reasonable from performance perspective when memory is fragmented as you
> described.

OK, but let's see the data.  *SHOW* me that it's slow. If the algorithm
works, then perhaps we can simply speed it up with a little caching and
*MUCH* less memory overhead.

-- Dave

