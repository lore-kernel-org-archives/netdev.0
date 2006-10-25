From: "Randy.Dunlap" <randy.dunlap@oracle.com>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Tue, 24 Oct 2006 21:52:15 -0700
Message-ID: <453EED7F.2010806@oracle.com>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org> <453ECB2C.3070202@candelatech.com> <20061025024718.GB23769@havoc.gtf.org> <20061024213549.92cbbeb0.randy.dunlap@oracle.com> <20061025044621.GA32486@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21750 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1161326AbWJYEus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 00:50:48 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061025044621.GA32486@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Tue, Oct 24, 2006 at 09:35:49PM -0700, Randy Dunlap wrote:
>>> Please grep for sysfs_create_bin_file, you will find plenty of examples.
>> Hm, I thought that sysfs binary files were supposed to be
>> for "transparent" blobs of data, not for structured data.
>> E.g., a "firmware" blob would be OK.
> 
> Depends.  Normally ASCII is greatly preferred, but passing in/out big
> data structures can be a huge pain, thunking to/from ASCII.
> 
> 
>> And I'm looking at current users.  ISTM that this one:
>>
>> arch/ppc/syslib/mv64x60.c:2443:	sysfs_create_bin_file(&mv64xxx_device.dev.kobj, &mv64xxx_hs_reg_attr);
>>
>> in its sysfs read function returns a string (binary data converted
>> to a string) instead of returning binary data.  Or did I misread it?
>> or misunderstand sysfs binary data?
> 
> Yeah, that one shouldn't be using _bin_

Thanks.  It's not the only one like that.  Also these 3 uses are incorrect AFAICT:

./drivers/firmware/dell_rbu.c:721:	rc = sysfs_create_bin_file(&rbu_device->dev.kobj, &rbu_data_attr);
./drivers/firmware/dell_rbu.c:724:	rc = sysfs_create_bin_file(&rbu_device->dev.kobj, &rbu_image_type_attr);
./drivers/firmware/dell_rbu.c:727:	rc = sysfs_create_bin_file(&rbu_device->dev.kobj,

-- 
~Randy
