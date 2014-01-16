From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] reciprocal_divide: correction/update of the algorithm
Date: Thu, 16 Jan 2014 11:26:18 +0100
Message-ID: <20140116102618.GA7436@order.stressinduktion.org>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com> <1389828228-30312-3-git-send-email-dborkman@redhat.com> <1389841646.31367.391.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Austin S Hemmelgarn <ahferroin7@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389841646.31367.391.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric!

On Wed, Jan 15, 2014 at 07:07:26PM -0800, Eric Dumazet wrote:
> On Thu, 2014-01-16 at 00:23 +0100, Daniel Borkmann wrote:
> 
> > Also, reciprocal_value() and reciprocal_divide() always return 0
> > for divisions by 1. This is a bit worrisome as those functions
> > also get used in mm/slab.c and lib/flex_array.c, apparently for
> > index calculation to access array slots. 
> 
> Hi Daniel
> 
> This off-by-one limitation is a known one,
> and mm/slab.c does not have an issue with it because :
> 
> - Minimal object size is not 1 byte, but 8 (or maybe 4)
> - We always divide a multiple of the divisor,
>   so there is no off-by-one effect.
> 
> Little attached prog does a brute force check if needed.
> 
> So far, the only relevant issue was about BPF, and a better
> documentation of reciprocal_divide() use cases.
> 
> (I let Jesse comment on the flex_array case)
> 
> I am unsure we want to 'fix' things, we tried hard in the past to avoid
> divides, so the ones we use are usually because the divisor is not
> constant, so the reciprocal doesn't help.
> 
> (BPF is fixed in David tree)
> 
> Thanks !

You are right, we rewrite that part. The text is still from the first commit
message where we did no full impact analysis. ;)

Thanks,

  Hannes
