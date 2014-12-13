From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Sat, 13 Dec 2014 11:13:38 +0800
Message-ID: <20141213031338.GA12208@richard>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20141205.213112.1199355931404701216.davem@davemloft.net>
 <1417844801.15618.30.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
 <20141208144237.GB8382@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gideonn@mellanox.com" <gideonn@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:38213 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964830AbaLMDNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 22:13:46 -0500
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 13 Dec 2014 13:13:44 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 708A22BB0055
	for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 14:13:41 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sBD3Dfd840304674
	for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 14:13:41 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sBD3DeqV026345
	for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 14:13:41 +1100
Content-Disposition: inline
In-Reply-To: <20141208144237.GB8382@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 08, 2014 at 10:42:37PM +0800, Wei Yang wrote:
>On Mon, Dec 08, 2014 at 10:00:19AM +0000, David Laight wrote:
>>From: Eric Dumazet
>>> On Fri, 2014-12-05 at 21:31 -0800, David Miller wrote:
>>> 
>>> > Guys, let's figure out what we are doing with this patch.
>>> > --
>>> 
>>> Oh well, patch is fine, please apply it, thanks !
>>
>>I'm not to sure that the patch doesn't generate a software byteswap
>>followed by a byteswapping write on ppc - clearly not ideal.
>>It might even generate back to back software byteswaps.
>>
>>If the write to the doorbell register includes a byteswap on BE (ppc)
>>then there is no real value in keeping the value as BE.
>>
>>OTOH ppc ought to have ways of doing IO writes without the byteswap
>>(and byteswapping accesses to non-io memory for that matter).
>>
>>What happens on a BE system with BE peripherals is another matter.
>
>David
>
>Thanks for your comment.
>
>How about use __raw_writel() to replace the iowrite32()? Looks this is better,
>if so, I will make up another version for this.
>

Hi, David

If you prefer this way, I would like to send a new version for this.
Is it ok for you?

>>
>>	David
>>
>
>-- 
>Richard Yang
>Help you, Help me

-- 
Richard Yang
Help you, Help me
