From: Peter Kjellstroem <cap@nsc.liu.se>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Sun, 5 Dec 2004 15:04:22 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0412051457030.13794-100000@papput.nsc.liu.se>
References: <1102216844.3343.84.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
In-Reply-To: <1102216844.3343.84.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello again,

I'm sorry my previous e-mail came out much more harsh then I intended it 
to (not native english speaking). I just wanted to point out that it's not 
falling over for me with all drivers.

I've been doing som more tests today to try to narrow down which patch 
causes my problems. So far I have this:

2.4.26 (5.2.30) is ok
2.4.28 (5.4.11) is not

2.4.28 with 5.2.30 patched in is ok
2.4.28 with 5.2.39 (from 2.4.27-pre1) is not

In e1000_main.c for 5.2.39 (from 2.4.27-pre1) i found this:

/* Change Log
 *
 * 5.2.39       3/12/04
 * ...
 *   o Back out the CSA fix for 82547 as it continues to cause
 *     systems lock-ups with production systems.

Best Regards,
 Peter

On Sat, 4 Dec 2004, Scott Feldman wrote:

> On Fri, 2004-12-03 at 11:02, Peter Kjellstroem wrote:
> > Short version: 82547GI with ITR=0 on 2.4.28 (vanilla) and RHEL3u3 has           
> > problems (traffic grinds to a temporary halt under anything but trivila         
> > network traffic). kernel prints the following and resets the IF (many           
> > times):                                                                         
> >                                                                                 
> > NETDEV WATCHDOG: eth0: transmit timed out           
> 
> Dude!  You're out of luck!
> 
> >From the README:
> 
>     CAUTION: If you are using the Intel PRO/1000 CT Network 
>              Connection (controller 82547), setting 
>              InterruptThrottleRate to a value
>              greater than 75,000, may hang (stop transmitting)
>              adapters under certain network conditions. If this
>              occurs a NETDEV WATCHDOG message is logged in the
>              system event log. In addition, the controller is
>              automatically reset, restoring the network
>              connection. To eliminate the potential for the hang,
>              ensure that InterruptThrottleRate is set no greater
>              than 75,000 and is not set to 0.
> 
> I was running into the same thing with 82547EI setting ITR=0, and then I
> remembered that this part is buggy when ITR=0.  The bug is due to 82547
> messing up the order of interrupt assertion and de-assertion on the CSA
> bus.
> 
> If you want to do MPI on this system, you'll need to use a non-zero ITR
> or plug in an add-in card into one of the PCI slots and use the add-in
> card.  The problem is, these slots are probably 32-bit/33Mhz, so you're
> not going to get the same maximum Mbps that you'll get with 82547 using
> the CSA bus.  82547 will not be a good choice for MPI.  Sorry.
> 
> > Affected chips (theory, 8254X, X>1 or anything faster then PCI33):
> > 82547GI, 82546 (said to be affected, not verified by me)
> 
> 82546 should be fine with ITR=0.
> 
> >  http://lists.us.dell.com/pipermail/linux-poweredge/2004-November/023061.html
> 
> You might want to forward this info to that thread.
> 
> -scott
> 
> 

-- 
------------------------------------------------------------
  Peter Kjellstroem              | E-mail: cap@nsc.liu.se
  National Supercomputer Centre  |
  Sweden                         | http://www.nsc.liu.se
