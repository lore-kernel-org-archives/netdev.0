From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] rhashtable: use cond_resched()
Date: Thu, 26 Feb 2015 16:03:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAEEEDF@AcuExch.aculab.com>
References: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>
 <20150226075354.GA30061@acer.localdomain>
 <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAEEE09@AcuExch.aculab.com>
 <20150226154643.GA18965@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Patrick McHardy' <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:52725 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbbBZQEo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:04:44 -0500
In-Reply-To: <20150226154643.GA18965@acer.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy [mailto:kaber@trash.net]
> On 26.02, David Laight wrote:
> > From: Eric Dumazet
> > Sent: 26 February 2015 15:21
> > > If a hash table has 128 slots and 16384 elems, expand to 256 slots
> > > takes more than one second. For larger sets, a soft lockup is detected.
> >
> > What on earth is it doing?
> > Presumably something to do with the rcu actions needed to allow
> > lockless lookup during resize.
> >
> > There has to be a better solution?
> > Perhaps even two sets of chain pointers down the hash lists.
> > Then the old hash table can be kept completely valid while the
> > whole 'unzip' action is done.
> 
> One of the main points of rhashtable is that you don't need those.

Would it be possible to keep the hash chains sorted into 'raw hash' order?
I think that would mean the 'unzip' only had to change a single linkage.

	David
