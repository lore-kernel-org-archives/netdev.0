From: Andrew Morton <akpm@digeo.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 14:58:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D87A59C.410FFE3E@digeo.com>
References: <3D87A264.8D5F3AD2@digeo.com> <20020917.143947.07361352.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: Andrew Morton <akpm@digeo.com>
>    Date: Tue, 17 Sep 2002 14:45:08 -0700
> 
>    "David S. Miller" wrote:
>    > Well, it is due to the same problems manfred saw initially,
>    > namely just a crappy or buggy NAPI driver implementation. :-)
> 
>    It was due to additional inl()'s and outl()'s in the driver fastpath.
> 
> How many?  Did the implementation cache the register value in a
> software state word or did it read the register each time to write
> the IRQ masking bits back?
> 

Looks like it cached it:

-    outw(SetIntrEnb | (inw(ioaddr + 10) & ~StatsFull), ioaddr + EL3_CMD);
     vp->intr_enable &= ~StatsFull;
+    outw(vp->intr_enable, ioaddr + EL3_CMD);

> It is issues like this that make me say "crappy or buggy NAPI
> implementation"
> 
> Any driver should be able to get the NAPI overhead to max out at
> 2 PIOs per packet.
> 
> And if the performance is really concerning, perhaps add an option to
> use MEM space in the 3c59x driver too, IO instructions are constant
> cost regardless of how fast the PCI bus being used is :-)

Yup.  But deltas are interesting.
