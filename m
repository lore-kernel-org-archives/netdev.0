From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
Date: Tue, 3 May 2005 13:05:15 +1000
Message-ID: <20050503030515.GD12682@krispykreme>
References: <200504051836.j35IanDD005402@guinness.s2io.com> <Pine.LNX.4.61.0505021459240.16692@linux.site> <20050503014034.GC12682@krispykreme> <Pine.LNX.4.61.0505021844480.16692@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leonid Grossman <leonid.grossman@neterion.com>,
        muhammad.shafiq@neterion.com, ramkrishna.vepa@neterion.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0505021844480.16692@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
Hi,

> I thought that an arch was supposed to define mmiowb() if it needs 
> it. In this case, the readq() is only being used for the side-effect 
> of ordering the previous writes (the neterion folks can correct me 
> if I'm wrong). 

The documentation suggests mmiowb does not do write posting:

      <para>
        In addition to write posting, on some large multiprocessing systems
        (e.g. SGI Challenge, Origin and Altix machines) posted writes won't
        be strongly ordered coming from different CPUs.  Thus it's important
        to properly protect parts of your driver that do memory-mapped writes
        with locks and use the <function>mmiowb</function> to make sure they
        arrive in the order intended.  Issuing a regular <function>readX
        </function> will also ensure write ordering, but should only be used
        when the driver has to be sure that the write has actually arrived
        at the device (not that it's simply ordered with respect to other
        writes), since a full <function>readX</function> is a relatively
        expensive operation.
      </para>

So if we require the write to be posted we will need the read. If
however we only need to order wrt subsequent IO writes then I agree
mmiowb can be used.

Anton
