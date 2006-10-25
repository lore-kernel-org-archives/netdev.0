From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Wed, 25 Oct 2006 14:26:15 -0700
Message-ID: <453FD677.7060405@intel.com>
References: <453F9D4A.8090306@users.sourceforge.net> <20061025185656.GA19037@electric-eye.fr.zoreil.com> <453FC693.10705@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:831 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1030385AbWJYV2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 17:28:18 -0400
To: Anders Grafstrom <grfstrm@users.sourceforge.net>
In-Reply-To: <453FC693.10705@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Francois Romieu wrote:
>> Anders Grafstrom <grfstrm@users.sourceforge.net> :
>> [...]
>>> I'm thinking something like this patch.
>>
>> I do not have the spec for the max duration at hand but it makes sense.
>>
>> Can you:
>> - decrease the duration of each sleep and increase the count of 
>> iterations
>> - put the break on a line of its own
>> - add a Signed-off-by: Foo Bar <baz@nit.fol> line
>> - Cc: jeff@garzik.org and Auke Kok <auke-jan.h.kok@intel.com>
> 
> I'm already checking out specs, which, for 8255x devices, are available 
> on http://e1000.sf.net/ .

okay, I don't think this is needed at all:

Allthough the spec itself didn't talk about phy reset times, I've ran this patch with 
some debugging output on a few boxes and did some speed/duplex settings, and the PHY 
reset returned succesfull after the very first mdio_read, which is before any msleep(10) 
is executed. That is also expected behaviour.

I think you might be confusing this with a MAC reset, which has a documented 10usec 
timeout (see 8255x developers manual). The driver already adheres to this by doing a 
20usec delay after software/selective resets.

which gets us back to the original problem: how did your driver end up in loopback mode? 
(and, how did you figure out that it did??).

Cheers,

Auke
