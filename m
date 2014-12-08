From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Mon, 8 Dec 2014 22:42:37 +0800
Message-ID: <20141208144237.GB8382@richard>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20141205.213112.1199355931404701216.davem@davemloft.net>
 <1417844801.15618.30.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"weiyang@linux.vnet.ibm.com" <weiyang@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gideonn@mellanox.com" <gideonn@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:37673 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbaLHOmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 09:42:45 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 9 Dec 2014 00:42:43 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6DB0C3578058
	for <netdev@vger.kernel.org>; Tue,  9 Dec 2014 01:42:40 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB8EgdpB39715040
	for <netdev@vger.kernel.org>; Tue, 9 Dec 2014 01:42:40 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB8Egc74027139
	for <netdev@vger.kernel.org>; Tue, 9 Dec 2014 01:42:39 +1100
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 08, 2014 at 10:00:19AM +0000, David Laight wrote:
>From: Eric Dumazet
>> On Fri, 2014-12-05 at 21:31 -0800, David Miller wrote:
>> 
>> > Guys, let's figure out what we are doing with this patch.
>> > --
>> 
>> Oh well, patch is fine, please apply it, thanks !
>
>I'm not to sure that the patch doesn't generate a software byteswap
>followed by a byteswapping write on ppc - clearly not ideal.
>It might even generate back to back software byteswaps.
>
>If the write to the doorbell register includes a byteswap on BE (ppc)
>then there is no real value in keeping the value as BE.
>
>OTOH ppc ought to have ways of doing IO writes without the byteswap
>(and byteswapping accesses to non-io memory for that matter).
>
>What happens on a BE system with BE peripherals is another matter.

David

Thanks for your comment.

How about use __raw_writel() to replace the iowrite32()? Looks this is better,
if so, I will make up another version for this.

>
>	David
>

-- 
Richard Yang
Help you, Help me
