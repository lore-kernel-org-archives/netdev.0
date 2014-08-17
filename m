From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: Add polling mode
Date: Sun, 17 Aug 2014 14:58:09 +0200
Message-ID: <20140817125809.GA22213@redhat.com>
References: <1407659404-razya@il.ibm.com>
	<20140810083035.0CF58380729@moren.haifa.ibm.com>
	<20140810194559.GA4344@redhat.com>
	<20140811.124621.576073630604147753.davem@davemloft.net>
	<20140812091850.GD6440@redhat.com>
	<OF93E480CE.EFA0854D-ONC2257D32.003BE092-C2257D32.003C1F49@il.ibm.com>
	<20140813121550.GA21026@redhat.com>
	<OFFB3DD9F0.3A92A6A0-ONC2257D37.0043D722-C2257D37.004522A0@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eran Raichstein <ERANRA@il.ibm.com>, kvm-owner@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	abel.gordon@gmail.com, Alex Glikson <GLIKSON@il.ibm.com>,
	Yossi Kuperman1 <YOSSIKU@il.ibm.com>,
	Joel Nider <JOELN@il.ibm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Razya Ladelsky <RAZYA@il.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <OFFB3DD9F0.3A92A6A0-ONC2257D37.0043D722-C2257D37.004522A0@il.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 17, 2014 at 03:35:39PM +0300, Razya Ladelsky wrote:
> > > 
> > > Hi Michael,
> > > 
> > > Sorry for the delay, had some problems with my mailbox, and I realized 
> 
> > > just now that 
> > > my reply wasn't sent.
> > > The vm indeed ALWAYS utilized 100% cpu, whether polling was enabled or 
> 
> > > not.
> > > The vhost thread utilized less than 100% (of the other cpu) when 
> polling 
> > > was disabled.
> > > Enabling polling increased its utilization to 100% (in which case both 
> 
> > > cpus were 100% utilized). 
> > 
> > Hmm this means the testing wasn't successful then, as you said:
> > 
> >    The idea was to get it 100% loaded, so we can see that the polling is
> >    getting it to produce higher throughput.
> > 
> > in fact here you are producing more throughput but spending more power
> > to produce it, which can have any number of explanations besides polling
> > improving the efficiency. For example, increasing system load might
> > disable host power management.
> >
> 
> Hi Michael,
> I re-ran the tests, this time with the  "turbo mode" and  "C-states" 
> features off.
> No Polling:
> 1 VM running netperf (msg size 64B): 1107 Mbits/sec
>  Polling:
> 1 VM running netperf (msg size 64B): 1572 Mbits/sec
> 
> 
> 
> 
> 
> 
> 
> As you can see from the new results, the numbers are lower, 
> but relatively (polling on/off) there's no change.
> Thank you,
> Razya

That was just one example. There many other possibilities.  Either
actually make the systems load all host CPUs equally, or divide
throughput by host CPU.

> 
>  
> 
> 
>  
> > 
> > > > -- 
> > > > MST
> > > > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
