From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 14:28:42 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
References: <200501071414.05126.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
In-Reply-To: <200501071414.05126.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 Jan 2005, Jeremy M. Guthrie wrote:
> I just updated the Intel Drivers to the latest on source-forge(5.6.10.1).  I 
> now see lower CPU usage but I am still dropping.
> 
> During a 60 second window the machine received 5,110,164 packets and dropped 
> 20461 or roughly 0.4% packet loss.
> 
NAPI will cause a very busy stack to force the network card to drop the 
data instead of the stack.  This is supposed to be a good thing because 
the hardware will be forced to drop the packet (hopefully) instead of 
interrupt rate thrashing your machine right when it needs the cpu to do 
other stuff.  This is supposed to be the saving grace of NAPI.

So, not to distract from the conversation, but in the interest (my
interest :-) ) of tuning your E1000, can you please send the output of
ethtool -S ethX for each interface?  This will help us figure out if there
is anything to tune in the driver (like number of rx buffers, etc)

Thanks,
  Jesse
