From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Sat, 04 Dec 2004 19:20:44 -0800
Message-ID: <1102216844.3343.84.camel@sfeldma-mobl.dsl-verizon.net>
References: <Pine.LNX.4.44.0412031833150.13794-100000@papput.nsc.liu.se>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Kjellstroem <cap@nsc.liu.se>
In-Reply-To: <Pine.LNX.4.44.0412031833150.13794-100000@papput.nsc.liu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-03 at 11:02, Peter Kjellstroem wrote:
> Short version: 82547GI with ITR=0 on 2.4.28 (vanilla) and RHEL3u3 has           
> problems (traffic grinds to a temporary halt under anything but trivila         
> network traffic). kernel prints the following and resets the IF (many           
> times):                                                                         
>                                                                                 
> NETDEV WATCHDOG: eth0: transmit timed out           

Dude!  You're out of luck!

>From the README:

    CAUTION: If you are using the Intel PRO/1000 CT Network 
             Connection (controller 82547), setting 
             InterruptThrottleRate to a value
             greater than 75,000, may hang (stop transmitting)
             adapters under certain network conditions. If this
             occurs a NETDEV WATCHDOG message is logged in the
             system event log. In addition, the controller is
             automatically reset, restoring the network
             connection. To eliminate the potential for the hang,
             ensure that InterruptThrottleRate is set no greater
             than 75,000 and is not set to 0.

I was running into the same thing with 82547EI setting ITR=0, and then I
remembered that this part is buggy when ITR=0.  The bug is due to 82547
messing up the order of interrupt assertion and de-assertion on the CSA
bus.

If you want to do MPI on this system, you'll need to use a non-zero ITR
or plug in an add-in card into one of the PCI slots and use the add-in
card.  The problem is, these slots are probably 32-bit/33Mhz, so you're
not going to get the same maximum Mbps that you'll get with 82547 using
the CSA bus.  82547 will not be a good choice for MPI.  Sorry.

> Affected chips (theory, 8254X, X>1 or anything faster then PCI33):
> 82547GI, 82546 (said to be affected, not verified by me)

82546 should be fine with ITR=0.

>  http://lists.us.dell.com/pipermail/linux-poweredge/2004-November/023061.html

You might want to forward this info to that thread.

-scott
