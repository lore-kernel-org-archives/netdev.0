From: Dave Watson <davejwatson@fb.com>
Subject: Re: BUG_ON(sg->sg_magic != SG_MAGIC) on tls socket.
Date: Fri, 11 Aug 2017 12:15:51 -0700
Message-ID: <20170811191551.GA44762@dhcp-172-26-121-1.dhcp.thefacebook.com>
References: <20170811185201.7afmkfa3cuoqm4u2@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Dave Jones <davej@codemonkey.org.uk>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58816 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753181AbdHKTQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 15:16:08 -0400
Content-Disposition: inline
In-Reply-To: <20170811185201.7afmkfa3cuoqm4u2@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 08/11/17 02:52 PM, Dave Jones wrote:
> kernel BUG at ./include/linux/scatterlist.h:189!
> invalid opcode: 0000 [#1] SMP KASAN

...

> Call Trace:
>  ? copy_page_to_iter+0x6c0/0x6c0
>  tls_sw_sendmsg+0x6d8/0x9c0
>  ? alloc_sg+0x510/0x510
>  ? cyc2ns_read_end+0x10/0x10
>  ? import_iovec+0xa8/0x1f0
>  ? do_syscall_64+0x1bc/0x3e0
>  ? entry_SYSCALL64_slow_path+0x25/0x25
>  inet_sendmsg+0xce/0x310

...

> 186 static inline void sg_mark_end(struct scatterlist *sg)
> 187 {
> 188 #ifdef CONFIG_DEBUG_SG
> 189         BUG_ON(sg->sg_magic != SG_MAGIC);
> 190 #endif

+added mellanox folks

I haven't seen this one yet.  The specific sequence of
sendmsg/sendpage calls would probably be super helpful to nail it down

Thanks
