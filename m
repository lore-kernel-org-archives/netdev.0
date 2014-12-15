From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Mon, 15 Dec 2014 11:59:15 +0200
Message-ID: <548EB0F3.4050802@mellanox.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
 <20141208144237.GB8382@richard> <20141213031338.GA12208@richard>
 <20141213.234320.1607496855879763694.davem@davemloft.net>
 <20141215013249.GA7341@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Gideon Naim <gideonn@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>
To: Wei Yang <weiyang@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0056.outbound.protection.outlook.com ([157.56.112.56]:56753
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752158AbaLOJ7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 04:59:32 -0500
In-Reply-To: <20141215013249.GA7341@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2014 3:32 AM, Wei Yang wrote:
[...]

Hi David's,

I need to do a native endianness write to the NIC register (the write is
on the fast path and the register value could be calculated once).

iowrite32be() is calling cpu_to_be32() on the value.
iowrite32() is calling cpu_to_le32().

I thought about using raw_writel() but as David Miller said, it lacks
necessary io barriers on some archs.

Does the only solution to this, is to add some sort of
iowrite32be_native(__be32 val,...) function to all the archs?

Thanks,
Amir
