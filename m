From: Patrick McHardy <kaber@trash.net>
Subject: Re: Connection tracking and vlan
Date: Mon, 02 Nov 2009 17:33:43 +0100
Message-ID: <4AEF09E7.2010004@trash.net>
References: <20091030152054.GA7936@gondor.apana.org.au>	 <4AEB06E6.6020206@gmail.com>	 <fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com>	 <m1639wmq1f.fsf@fess.ebiederm.org> <4AEB75DD.8050204@candelatech.com> <fb7befa20911020814q2c4bcd1bj7e2b5a4c17ba0f89@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Adayadil Thomas <adayadil.thomas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54333 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbZKBQdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 11:33:41 -0500
In-Reply-To: <fb7befa20911020814q2c4bcd1bj7e2b5a4c17ba0f89@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adayadil Thomas wrote:
> If the vlan id is used for hash, it still may not avoid the problem completely,
> i.e. in case of both connections hashing to the same bucket.
> 
> I was wondering about your opinion about adding an optional member to the tuple
> structure, vid (for vlan id).
>
> I have attached the patch for this change. I would be grateful for any comments
> such as dependencies on the rest of the system.

Absolutely not, conntrack is not meant to deal with anything below
the network layer and I don't want to add any hacks for the bridge
netfilter "integration", which has already caused an endless amount
of problems. Additionally this is just one of many possible identifiers
people might want to use to distinguish similar entries and has a
number of practical issues, like breaking asymetric setups using
different VLANs for each direction.

I might be willing to consider a generically usable numerical
identifier to distinguish similar entries, something like
"conntrack zones". This could also help with the defragmentation
issue discussed earlier, the identifier would also be added to
the defragmentation identifier, for asymetric setups the interfaces
would be put in the same "zone".

But it would be preferrable if we could do this using network
namespaces somehow.
