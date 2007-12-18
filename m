From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFC: igb: Intel 82575 gigabit ethernet driver (take #2)
Date: Tue, 18 Dec 2007 17:33:13 -0500
Message-ID: <47684AA9.9050409@pobox.com>
References: <475F107A.8080201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50386 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbXLRWdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 17:33:17 -0500
In-Reply-To: <475F107A.8080201@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks pretty decent.  Main comments (style mostly, driver operation path 
seems sound):

* kill the bitfields and unions [in descriptor structs].  they are not 
endian-safe as presented, generate poor code, and are otherwise undesirable.

* the basic operations are too verbose:  E1000_READ_REG(hw, REGISTER) is 
far more readable as ER32(REGISTER), following the style of other 
drivers.  Furthermore, the "E1000_" prefix, in addition to being overly 
redundant (used in each register read/write), it is also incorrect, 
because this is not E1000...

* in general, rename everything with "e1000_" prefix.  this will 
eliminate plenty of human confusion in the long run.

* API:   unless you have chips in the lab that will require an API hook, 
don't create one.  For example, a direct call to 
e1000_acquire_nvm_82575() should replace all ->acquire_nvm() hooks.... 
if there are no chips in pipeline GUARANTEED to have a different 
->acquire_nvm() feature.

In general, I try to communicate that I am not opposed to these hooks, 
you merely need to make sure they are needed in _each_ case.  Otherwise 
engineers WILL fall into the habit of writing bloated code simply 
because that's what their chosen driver framework has always done.

	Jeff








