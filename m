From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Mon, 15 Dec 2014 09:32:49 +0800
Message-ID: <20141215013249.GA7341@richard>
References: <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
 <20141208144237.GB8382@richard>
 <20141213031338.GA12208@richard>
 <20141213.234320.1607496855879763694.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, David.Laight@ACULAB.COM,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	gideonn@mellanox.com, edumazet@google.com, amirv@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:40108 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaLOBc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 20:32:58 -0500
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 15 Dec 2014 11:32:56 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8CD982CE8052
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 12:32:52 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sBF1Wplx27328598
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 12:32:52 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sBF1WoS2028457
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 12:32:51 +1100
Content-Disposition: inline
In-Reply-To: <20141213.234320.1607496855879763694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2014 at 11:43:20PM -0500, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Sat, 13 Dec 2014 11:13:38 +0800
>
>> On Mon, Dec 08, 2014 at 10:42:37PM +0800, Wei Yang wrote:
>> If you prefer this way, I would like to send a new version for this.
>> Is it ok for you?
>
>I'm not so sure.  There are implications when using the __raw_*()
>routines.
>
>In particular, using __raw_{read,write}l() also means that the usual
>necessary I/O memory barriers are not being performed.
>
>There are therefore no ordering guarantees between __raw_*() and other
>I/O or memory accesses whatsoever.

Thanks David.

Actually, the last mail is asking David Laight. I am trying to understanding
his comment and Amir told me he was suggesting to use __raw_*() version.

Hmm... this is really a problem found in the v3.18-rc1 and the root cause is
the endianess. I am ok to use any method to fix this problem, even revert it.
Could the maintainer from Mellanox gives me a word?

-- 
Richard Yang
Help you, Help me
