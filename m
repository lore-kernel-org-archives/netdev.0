From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 02 Jun 2005 22:32:33 -0400
Message-ID: <1117765954.6095.49.camel@localhost.localdomain>
References: <468F3FDA28AA87429AD807992E22D07E0450BFDB@orsmsx408>
	 <20050602.171812.48807872.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        mitch.a.williams@intel.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050602.171812.48807872.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-02-06 at 17:18 -0700, David S. Miller wrote:
> From: "Ronciak, John" <john.ronciak@intel.com>
> Date: Thu, 2 Jun 2005 17:11:20 -0700
> 
> > I like this idea as well but I do an issue with it.  How would this
> > stack code find out that the weight is too high and pacekts are being
> > dropped (not being polled fast enough)?  It would have to check the
> > controller stats to see the error count increasing for some period.  I'm
> > not sure this is workable unless we have some sort of feedback which the
> > driver could send up (or set) saying that this is happening and the
> > dynamic weight code could take into acount.
> 
> What more do you need other than checking the statistics counter?  The
> drop statistics (the ones we care about) are incremented in real time
> by the ->poll() code, so it's not like we have to trigger some
> asynchronous event to get a current version of the number.

I am reading through all the emails and I think either the problem is
not being clearly stated or not understood. I was going to say "or i am
on crack "- but I know i am clean ;-> 

Heres what i think i saw as a flow of events:
Someone posted a theory that if you happen to reduce the weight
(iirc the reduction was via a shift) then the DRR would give less CPU
time cycle to the driver - Whats the big suprise there? thats DRR design
intent.

Stephen has a patch which allows people to reduce the weight.
DRR  provides fairness. If you have 10 NICs coming at different wire
rates, the weights provide a fairness quota without caring about what
those speeds are. So it doesnt make any sense IMO to have the weight
based on what the NIC speed is. Infact i claim it is _nonsense_. You
dont need to factor speed. And the claim that DRR is not real world
is blasphemous.

Having said that:
I have a feeling that issue which is which is being waded around is the
amount that the softirq chews in the CPU (unfortunately a well known
issue) and to some extent the packet flow a specific driver chews
depending on the path it takes.
In other words, for DRR algorithm to enhance the fairness it should
consider not only fairness in the amounts of packets the driver injects
into the system but also the amount of CPU that driver chews. At the
moment we lump all drivers together as far as the CPU cycles are
concerned.
If we could narrow it down to this, then i think there is something that
could lead to meaningful discussion.
This, however, does not eradicate the need for DRR and is absolutely not
driver specific. 

cheers,
jamal
