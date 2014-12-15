From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Mon, 15 Dec 2014 10:00:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0CB3D@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
 <20141208144237.GB8382@richard> <20141213031338.GA12208@richard>
 <20141213.234320.1607496855879763694.davem@davemloft.net>
 <20141215013249.GA7341@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gideonn@mellanox.com" <gideonn@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>
To: 'Wei Yang' <weiyang@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47465 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751828AbaLOKBj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 05:01:39 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17903-10 for <netdev@vger.kernel.org>;
 Mon, 15 Dec 2014 10:01:31 +0000 (GMT)
In-Reply-To: <20141215013249.GA7341@richard>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang
> On Sat, Dec 13, 2014 at 11:43:20PM -0500, David Miller wrote:
> >From: Wei Yang <weiyang@linux.vnet.ibm.com>
> >Date: Sat, 13 Dec 2014 11:13:38 +0800
> >
> >> On Mon, Dec 08, 2014 at 10:42:37PM +0800, Wei Yang wrote:
> >> If you prefer this way, I would like to send a new version for this.
> >> Is it ok for you?
> >
> >I'm not so sure.  There are implications when using the __raw_*()
> >routines.
> >
> >In particular, using __raw_{read,write}l() also means that the usual
> >necessary I/O memory barriers are not being performed.
> >
> >There are therefore no ordering guarantees between __raw_*() and other
> >I/O or memory accesses whatsoever.
> 
> Thanks David.
> 
> Actually, the last mail is asking David Laight. I am trying to understanding
> his comment and Amir told me he was suggesting to use __raw_*() version.

I don't know (off hand) which of the access functions contain byteswaps and
memory barriers, from trying to get some drivers running on ppc I know the
whole thing is a complete mess (beats me why all the on-chip devices of
opposite endianness to the cpu iteself).

In this case you seem to have an earlier change to store the value that
doesn't need a byteswap on write (for efficiency), then are using an
access function that does a byteswapping write to memory (efficient, but
the wrong value), and are fixing it by adding another byteswap (inefficient)
prior to the byteswapping write.

So you should either be using a non-byteswapping write, of just save
the byteswapped value so that the written value is correct.

	David

> Hmm... this is really a problem found in the v3.18-rc1 and the root cause is
> the endianess. I am ok to use any method to fix this problem, even revert it.
> Could the maintainer from Mellanox gives me a word?
> 
> --
> Richard Yang
> Help you, Help me
