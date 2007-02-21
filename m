From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 10:38:22 +0100
Message-ID: <200702211038.24349.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <200702211015.11975.dada1@cosmosbay.com> <20070221092717.GA15669@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:52954 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030573AbXBUJif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 04:38:35 -0500
In-Reply-To: <20070221092717.GA15669@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 21 February 2007 10:27, Evgeniy Polyakov wrote:
> On Wed, Feb 21, 2007 at 10:15:11AM +0100, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > On Wednesday 21 February 2007 09:54, Evgeniy Polyakov wrote:
> > > I shown that numbers 4 times already, do you read mails and links?
> > > Did you see an artifact Eric showed with his data?
> >
> > I showed all your thinking is wrong.
>
> You mix all the time distribution fairness and complexity of searching
> for collisions. Jenkins hash is unfair - having Linux random generator
> as attacker's tool we end up in the case, when jenkins hash has some
> chains with 5 times longer length.
>
> Short history:
> I showed that jenkins is unfair, you confirmed that with your data.
> Another question is about complexity of searching for collisions - you
> showed that with xor it is quite easy and with jenkins it is complex,
> then I showed that it is not that complex to find collisions in jenkins
> too.

Again here is your 'test'

enter_hash(u32 val)
{
counter[val & mask]++;
}

for (i = 0 ; i < 1000 ; i++)
  enter_hash(CONSTANT1)
for (i = 0 ; i < 1000 ; i++)
  enter_hash(CONSTANT2)

Oh my god, I have two chains with 1000 elems in it.

Real data are :
1) XOR hash, with a load factor of 0.41

Distribution of sockets/chain length
[chain length]:number of sockets
[0]:752255 0%
[1]:208850 47.455%
[2]:54281 72.1225%
[3]:19236 85.235%
[4]:8199 92.6869%
[5]:3487 96.6485%
[6]:1489 98.6785%
[7]:515 99.4976%
[8]:192 99.8466%
[9]:53 99.955%
[10]:14 99.9868%
[11]:3 99.9943%
[12]:1 99.997%
[13]:1 100%
total : 440101 sockets, Avg lookup cost=3.07896 cache lines

2) Jenkins hash, same load factor
[0]:688813 0%
[1]:289874 65.8653%
[2]:60452 93.3372%
[3]:8493 99.1266%
[4]:879 99.9255%
[5]:62 99.9959%
[6]:3 100%
total : 440101 sockets, Avg lookup cost=2.4175 cache lines



