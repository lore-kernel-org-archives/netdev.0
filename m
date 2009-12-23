From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH v2 03/12] ixgbevf: Mailbox communication
Date: Wed, 23 Dec 2009 13:38:47 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07559A5CD827@orsmsx508.amr.corp.intel.com>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
	 <20091218225140.10698.50205.stgit@localhost.localdomain>
 <1261600088.2782.72.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25009 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbZLWVit convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 16:38:49 -0500
In-Reply-To: <1261600088.2782.72.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Wednesday, December 23, 2009 12:28 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V
>Subject: Re: [RFC PATCH v2 03/12] ixgbevf: Mailbox communication
>
>On Fri, 2009-12-18 at 14:51 -0800, Jeff Kirsher wrote:
>> From: Greg Rose <gregory.v.rose@intel.com>
>>
>> The 82599 virtual function device and the master 82599 physical
>function
>> device implement a mailbox utility for communication between the
>devices
>> using some SRAM scratch memory and a doorbell/answering mechanism
>enabled
>> via interrupt and/or polling.  This C module and accompanying header
>> file implement the base functions for use of this feature.
>[...]
>> diff --git a/drivers/net/ixgbevf/mbx.c b/drivers/net/ixgbevf/mbx.c
>> new file mode 100644
>> index 0000000..a6e81fe
>> --- /dev/null
>> +++ b/drivers/net/ixgbevf/mbx.c
>[...]
>> +/**
>> + *  ixgbevf_poll_for_msg - Wait for message notification
>> + *  @hw: pointer to the HW structure
>> + *
>> + *  returns 0 if it successfully received a message notification
>> + **/
>> +static s32 ixgbevf_poll_for_msg(struct ixgbe_hw *hw)
>> +{
>> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
>> +	int countdown = mbx->timeout;
>> +
>> +	if (!mbx->ops.check_for_msg)
>> +		goto out;
>[...]
>
>Can this ever be true?

In this case no.

>Wouldn't that be a bug?

Most definitely.

>
>There are several similar, apparently unnecessary, tests in the
>following functions.

Yeah, the code was derived from a more general purpose code base.  I'll remove these unnecessary tests from the kernel driver.

Regards,

- Greg

