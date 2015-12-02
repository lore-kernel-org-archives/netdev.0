From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 02 Dec 2015 05:25:33 -0800
Message-ID: <1449062733.32764.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
	 <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
	 <20151201.143047.82022857078130793.davem@davemloft.net>
	 <CA+sq2CduMnsh_R9zTRMjWT=F5=9U3si-5nO6-gFvGCO9czkDdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Pavel Fedin <p.fedin@samsung.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+sq2CduMnsh_R9zTRMjWT=F5=9U3si-5nO6-gFvGCO9czkDdA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-02 at 11:18 +0530, Sunil Kovvuri wrote:
> >The driver should successfully recover from out of memory situations
> > and not stop RX/TX completely.
> This memory allocation is while interface bringup/initialization and not during
> packet I/O.
> 
> >Don't put this off as not "related" to your patch, it is as this
> >introduces the behavior for this user, and you should fix it before
> >expecting me to apply this patch series.
> I would disagree on this, as this patch hasn't introduced any failure here,
> if this user has connected any device which asks for a bit large amount
> of coherent memory then i am sure he will see the same issue.
> And above i have suggested what could be done to not see this issue.


This is unacceptable.

Maybe you did not complete tests. changelog has no 'Tested:' section.

You can not claim this patch was good, especially considering no precise
numbers were given.

If the performance increase is 4 %, then surely using twice more memory
is not worth it.

RX/TX ring buffer sizes should be :

- Default to reasonable sizes (ie not gigantic memory usage for typical
use). For multiqueue devices, one also has to take into account the
number of queues: 

  If a 10Gbit NIC has 128 queues, then probably having 8192 slots
  per queue is too much, if this maps to 512 MB of memory !

- ethtool -G support to let the admin change the conservative settings
for the exceptional workloads.
