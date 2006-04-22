From: "alpha @ steudten Engineering" <alpha@steudten.com>
Subject: Re: Fw: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c,
 iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered
Date: Sat, 22 Apr 2006 09:56:07 +0200
Message-ID: <4449E197.1020102@steudten.org>
References: <20060421102757.45d26db0@localhost.localdomain>	<200604211945.37129.netdev@axxeo.de> <20060421161227.00d688d6.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <netdev@axxeo.de>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Richard Henderson <rth@twiddle.net>, shemminger@osdl.org,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ioe-lkml@rameria.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:34722 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1750878AbWDVSLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 14:11:07 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060421161227.00d688d6.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Running this on my alpha gives (gcc 4.0.2):

3000
0123456A01234567


Andrew Morton wrote:

>> Because networking does read/write "short" fields in various packet
>> header structures. Results are illustrated in a following example:
>>
>> char foo[] __attribute__((aligned(8))) = "0123456701234567";
>>
>> int main()
>> {
>> 	short *bar = (short *)&foo[7];
>> 	printf("%04x\n", *bar); /* 3037 */
>> 	*bar = 0x4241; /* "AB" */
>> 	printf("%s\n", foo);
>> 	return 0;
>> }
>> --------
>> 0037
>> ^^
>> 0123456A01234567
>>         ^
>> Misalignment by two bytes for ints and longs is often unavoidable in
>> networking and we can cope with it, but there is no excuse of 1-byte
>> misalignment.


