From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred expansion/shrinking
Date: Sat, 17 Jan 2015 09:51:46 +0000
Message-ID: <7AE5EEE0-60C7-43B4-848A-2D952D3A6DEF@trash.net>
References: <20150116163202.GJ30132@acer.localdomain> <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com> <20150116165302.GE15052@casper.infradead.org> <20150116183626.GS30132@acer.localdomain> <20150116191831.GA26730@casper.infradead.org> <20150116193557.GU30132@acer.localdomain> <20150116204921.GA14833@gondor.apana.org.au> <20150116213156.GA7109@acer.localdomain> <20150117003340.GA16374@gondor.apana.org.au> <20150117080621.GB3968@acer.localdomain> <20150117093228.GA19137@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150117093228.GA19137@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 17. Januar 2015 09:32:28 GMT+00:00, schrieb Herbert Xu <herbert@gondor.apana.org.au>:
>On Sat, Jan 17, 2015 at 08:06:21AM +0000, Patrick McHardy wrote:
>> 
>> Resizing might also fail because of memory allocation problems, but
>> I'd argue that its better to continue with a non-optimal sized table
>> and retry later than to completely fail, at least unless the API
>> user has explicitly requested this behaviour.
>> 
>> As for the element counter, yeah, it should prevent overflow. In that
>> case I agree that failing insertion is the easiest solution.
>
>Well you have to consider the security aspect.  These days root-
>only is no longer an acceptable excuse given things like namespaces.
>
>If you don't fail the insertions while the expansion is ongoing,
>and assuming a dump can postpone expansions, then you can essentially
>insert entries into the hash table at will which is an easy DoS
>attack.

I agree, however at least in the case of nftables you can easily do the same thing by adding millions of rules.

It doesn't make things worse.

>Note that you don't have to fail the insertion right away.  I
>think waiting until you reach max * 2 would be fine.



