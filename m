From: Peter Kjellstroem <cap@nsc.liu.se>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Sun, 5 Dec 2004 13:42:08 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0412051338170.13794-100000@papput.nsc.liu.se>
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

Scott,

If you had read my entire message you could have noticed that 82547GI 
works fully ok (weeks of MPI stress) with 5.2.30 as shipped with 2.4.26. 
Also, setting it to less then 75K is not enough, it just gets harder to 
provoke, I have managed to make it die with 20K.

I will probably run a 2.4.28 with an e1000 driver from 2.4.26 (tested and 
ok) but I'm not really happy about adding another path to the list of 
stuff I have to push into a vanilla 2.4.28. Smells driver problem to me.

Regards,
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
  National Supercomputer Centre  | Office: +46(0)13 281492
  Linkoeping University          | Fax   : +46(0)13 282535
  SE-581 83 Linkoeping           | 
  Sweden                         | http://www.nsc.liu.se
