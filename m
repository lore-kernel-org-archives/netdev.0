From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen-netback: prefer xenbus_scanf()
 over xenbus_gather()
Date: Thu, 07 Jul 2016 04:06:52 -0600
Message-ID: <577E45DC02000078000FC178@prv-mh.provo.novell.com>
References: <577E279D02000078000FBEBF@prv-mh.provo.novell.com>
 <577E2719.6000303@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Wei Liu" <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: "David Vrabel" <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:59924 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbcGGKGx convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Thu, 7 Jul 2016 06:06:53 -0400
In-Reply-To: <577E2719.6000303@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 07.07.16 at 11:55, <david.vrabel@citrix.com> wrote:
> On 07/07/16 08:57, Jan Beulich wrote:
>> --- 4.7-rc6-prefer-xenbus_scanf.orig/drivers/net/xen-netback/xenbus.c
>> +++ 4.7-rc6-prefer-xenbus_scanf/drivers/net/xen-netback/xenbus.c
>> @@ -842,16 +842,16 @@ static int connect_ctrl_ring(struct back
>>  	unsigned int evtchn;
>>  	int err;
>>  
>> -	err = xenbus_gather(XBT_NIL, dev->otherend,
>> -			    "ctrl-ring-ref", "%u", &val, NULL);
>> -	if (err)
>> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
>> +			   "ctrl-ring-ref", "%u", &val);
>> +	if (err <= 0)
> 
> < 0

I disagree, as said elsewhere. If you feel like adjusting existing
instances is unnecessary, then drop those patches on the floor.
But I don't like to submit new uses with such a bogus check.

Jan
