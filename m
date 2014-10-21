From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation: ptp: Fix build failure on MIPS cross
 builds
Date: Tue, 21 Oct 2014 12:35:44 -0400 (EDT)
Message-ID: <20141021.123544.9516812519754063.davem@davemloft.net>
References: <1413794538-28465-1-git-send-email-markos.chandras@imgtec.com>
	<20141021110724.GA16479@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: markos.chandras@imgtec.com, linux-mips@linux-mips.org,
	corbet@lwn.net, netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141021110724.GA16479@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 21 Oct 2014 13:07:25 +0200

> On Mon, Oct 20, 2014 at 09:42:18AM +0100, Markos Chandras wrote:
>> diff --git a/Documentation/ptp/Makefile b/Documentation/ptp/Makefile
>> index 293d6c09a11f..397c1cd2eda7 100644
>> --- a/Documentation/ptp/Makefile
>> +++ b/Documentation/ptp/Makefile
>> @@ -1,5 +1,15 @@
>>  # List of programs to build
>> +ifndef CROSS_COMPILE
>>  hostprogs-y := testptp
>> +else
>> +# MIPS system calls are defined based on the -mabi that is passed
>> +# to the toolchain which may or may not be a valid option
>> +# for the host toolchain. So disable testptp if target architecture
>> +# is MIPS but the host isn't.
>> +ifndef CONFIG_MIPS
>> +hostprogs-y := testptp
>> +endif
>> +endif
> 
> It seems like a shame to simply give up and not compile this at all.
> Is there no way to correctly cross compile this for MIPS?

Yeah seriously, we should try to make this work instead of throwing our
hands in the air.
