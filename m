From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH 29/29] fm10k: Add support for PTP
Date: Sat, 20 Sep 2014 14:37:02 -0700
Message-ID: <1411249022.10610.9.camel@joe-AO725>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
	 <20140918224042.10373.93162.stgit@ahduyck-bv4.jf.intel.com>
	 <20140919173504.GA4136@localhost.localdomain> <541C76B8.6040708@intel.com>
	 <20140920210704.GA5258@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0232.hostedemail.com ([216.40.44.232]:34992 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755162AbaITVhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:37:07 -0400
In-Reply-To: <20140920210704.GA5258@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 23:07 +0200, Richard Cochran wrote:
> On Fri, Sep 19, 2014 at 11:32:24AM -0700, Alexander Duyck wrote:
> > Because doing it that way it extends over 80 characters.
> 
> Obviously, but still the result is really ugly.

True.

It might be reasonable to add a new container_of_ptr
to kernel.h

Something like:

/**
 * container_of_ptr - cast a member of a pointer to a structure
 *		      out to the containing structure
 * @ptr:	the pointer to the member.
 * @type_ptr:	a pointer of type of the container struct this is embedded in.
 * @member:	the name of the member within the type_ptr.
 *
 */
#define container_of_ptr(ptr, type_ptr, member)				\
({									\
	const typeof((type_ptr)->member) *__mptr = (ptr);		\
	(type_ptr)((char *)__mptr -					\
		   ((char *)&((ptr_type)->member) - (char *)(ptr_type))); \
})

So this could be written as:

	struct fm10k_intfc *interface = container_of_ptr(hw, interface, hw);
