From: "David S. Miller" <davem@redhat.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 14:39:47 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020917.143947.07361352.davem@redhat.com>
References: <3D879F59.6BDF9443@digeo.com>
	<20020917.142635.114214508.davem@redhat.com>
	<3D87A264.8D5F3AD2@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
In-Reply-To: <3D87A264.8D5F3AD2@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Tue, 17 Sep 2002 14:45:08 -0700

   "David S. Miller" wrote:
   > Well, it is due to the same problems manfred saw initially,
   > namely just a crappy or buggy NAPI driver implementation. :-)
   
   It was due to additional inl()'s and outl()'s in the driver fastpath.
   
How many?  Did the implementation cache the register value in a
software state word or did it read the register each time to write
the IRQ masking bits back?

It is issues like this that make me say "crappy or buggy NAPI
implementation"

Any driver should be able to get the NAPI overhead to max out at
2 PIOs per packet.

And if the performance is really concerning, perhaps add an option to
use MEM space in the 3c59x driver too, IO instructions are constant
cost regardless of how fast the PCI bus being used is :-)
