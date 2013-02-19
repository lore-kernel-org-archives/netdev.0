From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v6 08/46] CPU hotplug: Provide APIs to prevent CPU offline from atomic context
Date: Tue, 19 Feb 2013 10:42:53 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7154@saturn3.aculab.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123920.26245.56709.stgit@srivatsabhat.in.ibm.com> <CANN689HhVxDv+3Bn9UAxOMzj0egTvVp_c7oAmQ2nnQ8Xjn_aMA@mail.gmail.com> <51225A36.40600@linux.vnet.ibm.com> <CANN689FJPLfz06MFRJ9T+BuToejAzjYP_yrw_H4iGi1Kb3p2-g@mail.gmail.com> <51227810.6090009@linux.vnet.ibm.com> <CANN689E-98zK69pGeojbm30n3sswQYVBvhk3i3OzqvbeqSrSrg@mail.gmail.com> <51234C23.2030909@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <tglx@linutronix.de>, <peterz@infradead.org>, <tj@kernel.org>,
	<oleg@redhat.com>, <paulmck@linux.vnet.ibm.com>,
	<rusty@rustcorp.com.au>, <mingo@kernel.org>,
	<akpm@linux-foundation.org>, <namhyung@kernel.org>,
	<rostedt@goodmis.org>, <wangyun@linux.vnet.ibm.com>,
	<xiaoguangrong@linux.vnet.ibm.com>, <rjw@sisk.pl>, <sbw@mit.edu>,
	<fweisbec@gmail.com>, <linux@arm.linux.org.uk>,
	<nikunj@linux.vnet.ibm.com>, <linux-pm@vger.kernel.org>,
	<linux-arch@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<vincent.guittot@linaro.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	"Michel Lespinasse" <walken@google.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <51234C23.2030909@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I wouldn't go that far... ;-) Unfairness is not a show-stopper right?
> IMHO, the warning/documentation should suffice for anybody wanting to
> try out this locking scheme for other use-cases.

I presume that by 'fairness' you mean 'write preference'?

I'd not sure how difficult it would be, but maybe have two functions
for acquiring the lock for read, one blocks if there is a writer
waiting, the other doesn't.

That way you can change the individual call sites separately.

The other place I can imagine a per-cpu rwlock being used
is to allow a driver to disable 'sleep' or software controlled
hardware removal while it performs a sequence of operations.

	David
