From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: Sun, 25 Jan 2004 09:56:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <009001c3e36c$9b6f1f70$0400a8c0@S2IOtech.com>
References: <20040124155809.15fe167e.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <hadi@cyberus.ca>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Andi Kleen'" <ak@suse.de>
In-Reply-To: <20040124155809.15fe167e.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> > In Linux, there are couple performance issues that we see
> > - transmit performance is noticeably worse than in Windows
> 
> In Linux 2.6 with TSO?

You are right, sorry.. It's TS0 not LSO in Linux and Unix. After doing
first ndis Send offload implementation back at Alteon, LSO acronym got
engraved into my brain :-)

> 
> Other than that I would suggest to enable oprofile on 2.6 and post 
> the profile numbers on the list.

Will do. Also - it's a bit embarrassing to admit but I suspect 2.6
installations that my test and development teams do are still more art
than science, I'm not sure we always end up with a trusted setup. Could
someone point me towards a good description of upgrading to 2.6 kernel,
either from RH AS 3.0 or from Suse distribution?

> 
> > - checksum in 2.4 seems to be calculated by the host even if the 
> > device enables checksum offload
> 
> You have to use sendfile() for TX checksum off load. Without that the 
> data needs to be copied anyways and a copy+csum is about the 
> same cost as a simple copy.

We've done couple quick tests on this recently with benchmarking
software - Chariot has some scripts that use sendfile(), and also one of
nttcp versions has -f option. In both cases, using sendfile() did not
seem to improve the maximum send performance on 10GbE; we are planning
to do some more testing though... 

> 
> > - Large Send Offload in 2.6 (no LSO in 2.4) give much smaller boost 
> > comparing to Windows; on some systems there is no gain from LSO at 
> > all.
> 
> You mean TSO? Are you sure the test programs submitted big enough 
> buffers to the TCP stack?

The driver is definitely getting large send requests, if this is what
you are asking. Our testing with 2.6 up to date is pretty limited, but
on some server configurations we see some noticeable performance gain
from TSO (the gain is smaller than from LSO in Windows though), on other
setups performance with TSO enabled is the same or even less that
without TSO enabled. 

Thanks for the advice, looks like we have couple things to try.
Regards, Leonid
>  
> 
> -Andi
> 
