From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] reciprocal_divide: correction/update of
 the algorithm
Date: Thu, 16 Jan 2014 18:50:39 +0000
Message-ID: <1389898239.11912.61.camel@bwh-desktop.uk.level5networks.com>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
	 <1389828228-30312-3-git-send-email-dborkman@redhat.com>
	 <alpine.DEB.2.10.1401161036110.29778@nuc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Austin S Hemmelgarn <ahferroin7@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"Veaceslav Falico" <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Jakub Zawadzki" <darkjames-ws@darkjames.pl>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1401161036110.29778@nuc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-16 at 10:37 -0600, Christoph Lameter wrote:
> On Thu, 16 Jan 2014, Daniel Borkmann wrote:
> 
> > - * or else the performance is slower than a normal divide.
> > - */
> > -extern u32 reciprocal_value(u32 B);
> > +struct reciprocal_value {
> > +	u32 m;
> > +	u8 sh1, sh2;
> > +};
> >
> > +#define RECIPROCAL_VALUE_RESULT_TO_ZERO ((struct reciprocal_value){.sh1 = 32})
> >
> > -static inline u32 reciprocal_divide(u32 A, u32 R)
> > +struct reciprocal_value reciprocal_value(u32 d);
> 
> A function that returns a struct? That works? Which gcc versions support
> it?

At least since gcc 1.29, given:

Thu Sep 22 15:57:41 1988  Richard Stallman  (rms at sugar-bombs.ai.mit.edu)
[...]
	* stmt.c (expand_function_start): Set current_function_needs_context
	and current_function_returns_struct.

Hope that's not a problem...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
