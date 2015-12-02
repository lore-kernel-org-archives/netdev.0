From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 07:11:56 -0500
Message-ID: <20151202121156.GK23178@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
 <20151201183720.GE21252@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/02/15 11:56), David Laight wrote:
> >                 Gbps  peak cpu util
> > esp-null         1.8   71%
> > aes-gcm-c-256    1.6   79%
> > aes-ccm-a-128    0.7   96%
> > 
> > That trend made me think that if we can get esp-null to be as close
> > as possible to GSO/GRO, the rest will follow closely behind.
> 
> That's not how I read those figures.
> They imply to me that there is a massive cost for the actual encryption
> (particularly for aes-ccm-a-128) - so whatever you do to the esp-null
> case won't help.

I'm not a crypto expert, but my understanding is that the CCM mode
is the "older" encryption algorithm, and GCM is the way of the future.
Plus, I think the GCM mode has some type of h/w support (hence the
lower cpu util)

I'm sure that crypto has a cost, not disputing that, but my point
was that 1.8 -> 1.6 -> 0.7 is a curve with a much gentler slope than
the 9 Gbps (clear traffic, GSO, GRO) 
    -> 4 Gbps (clear, no gro, gso) 
       -> 1.8 (esp-null)
That steeper slope smells of s/w perf that we need to resolve first,
before getting into the work of faster crypto?

> One way to get a view of the cost of the encryption (and copies)
> is to do the operation twice.

I could also just instrument it with perf tracepoints, if that 
data is interesting

--Sowmini
