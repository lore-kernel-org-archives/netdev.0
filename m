From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH 03/22] ixgb: Write RA register high word first, increment version
Date: Mon, 11 Dec 2006 14:07:56 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52016AFF8C@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19258 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763151AbWLKWID convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 17:08:03 -0500
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
>> -		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
>> +		/* Write high reg first to disable the AV bit first */
>>  		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
>> +		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
> 
> Are you sure the order is guaranteed even after this code change, when
> considering all manner of CPU and bus posted writes?
> 
> ACK if yes

AFAIK, yes, because a bus controller should not be able to write combine
address sequence 4,0,12,8 into 0-12, because that would be reordering
writes.

I've only seen a strangely configured AMD 8132 bridge write combine
*linear* writes like this 0,4,8,12 into 0-12, so you can either reorder
the writes *or* put in a write flush between linear writes to work
around any issues created by write combining register writes.

In any case I believe this work around to be okay.
--
Jesse
