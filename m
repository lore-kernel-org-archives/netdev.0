From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC net-next] bnx2x: avoid printing unnecessary messages
 during register dump
Date: Thu, 29 Sep 2016 13:19:39 -0300
Message-ID: <57ED3F1B.2040602@linux.vnet.ibm.com>
References: <1475001234-25933-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <20160927.224349.354006077948089224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ariel.elior@qlogic.com,
        Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50706 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755412AbcI2QTt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:19:49 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8TGIxd1088441
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 12:19:49 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25s25swace-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 12:19:48 -0400
Received: from localhost
        by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 13:19:46 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
        by d24dlp01.br.ibm.com (Postfix) with ESMTP id 278F5352005F
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 12:19:19 -0400 (EDT)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
        by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8TGJhAT4960354
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 13:19:43 -0300
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
        by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8TGJhW7007908
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 13:19:43 -0300
In-Reply-To: <20160927.224349.354006077948089224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/27/2016 11:43 PM, David Miller wrote:
> From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
> Date: Tue, 27 Sep 2016 15:33:54 -0300
> 
>> The bnx2x driver prints multiple error messages during register dump,
>> with "ethtool -d" for example. The driver even warn that many messages
>> might be seen during the register dump, but they are harmless. A typical
>> kernel log after register dump looks like this:
>>
>>   [9.375] bnx2x: [bnx2x_get_regs:987(net0)]Generating register dump. Might trigger harmless GRC timeouts
>>   [9.439] bnx2x: [bnx2x_attn_int_deasserted3:4342(net0)]LATCHED attention 0x04000000 (masked)
>>   [9.439] bnx2x: [bnx2x_attn_int_deasserted3:4346(net0)]GRC time-out 0x010580cd
>>   [...]
>>
>> The notation [...] means that some messages were supressed - in our
>> tests we saw 78 more "LATCHED attention" and "GRC time-out" messages,
>> supressed here.
>>
>> This patch avoid these messages to be printed on register dump instead
>> of just warn they are harmless.
>>
>> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> 
> Although "ethtool -d" is really a debugging facility, I still think that
> serious care should be placed into arranging what gets dumped in such
> a way that such access timeouts and errors are minimized.
> 

David, thanks for your comment. I confess I didn't understand your
statement quite well. You say we shouldn't dump registers that will
cause timeouts, that's it?

If yes, I guess this is a valid point. We will however loose some debug
information (as you mentioned, 'ethtool -d' is a debug facility). Now,
since I'm no expert in QLogic adapter hw/fw, I want to ask Yuval/Ariel
why those timeouts are hit anyway. Are they completely harmless?

In my understanding/opinion, hiding the messages entirely (as this patch
does) OR avoid the timeouts by disabling some registers' dump are both
better alternatives than the current behavior of the driver.

Thanks,



Guilherme
