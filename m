From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: fix strlen errors in sysfs
Date: Thu, 14 Jul 2011 09:02:06 -0700
Message-ID: <9576.1310659326@death>
References: <1310608665-12216-1-git-send-email-andy@greyhouse.net> <201107141115.35452.vitas@nppfactor.kiev.ua>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Takuma Umeya <tumeya@redhat.com>
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:48522 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755271Ab1GNQEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 12:04:46 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6EFfPZD029452
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2011 11:41:25 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6EG3Qen130080
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2011 12:03:27 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6EG2F8w021629
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2011 10:02:16 -0600
In-reply-to: <201107141115.35452.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitalii Demianets <vitas@nppfactor.kiev.ua> wrote:

>On Thursday 14 July 2011 04:57:45 Andy Gospodarek wrote:
>> -			if (strnicmp
>> -			    (slave->dev->name, buf,
>> -			     strlen(slave->dev->name)) == 0) {
>> +			int max_len = max(strlen(slave->dev->name),
>> +					  strlen(buf) - 1);
>> +			if (strnicmp(slave->dev->name, buf, max_len) == 0) {
>
>As for me there is no sense in preventing "address out of range" errors in  
>strnicmp by calculating length with strlen first. If there is missing \0 at 
>the end of the string you just shift failure point from stricmp to the strlen 
>function call.
>IMHO "maximum length" argument in strnicmp should be some appropriate constant 
>instead. Alternatively we can use count:

	I agree about using a constant, and I nominate IFNAMSIZ for that
constant.

	Also, should we really be using strnicmp?  I.e., case
insensitive?  Aren't interface names case sensitive?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
