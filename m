From: jamal <hadi@cyberus.ca>
Subject: RE: Intel and TOE in the news
Date: 21 Feb 2005 08:44:58 -0500
Message-ID: <1108993498.1089.149.camel@jzny.localdomain>
References: <200502202244.j1KMinDD013572@guinness.s2io.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>, "'rick jones'" <rick.jones2@hp.com>,
        netdev@oss.sgi.com, "'Alex Aizman'" <alex@neterion.com>
To: Leonid Grossman <leonid.grossman@neterion.com>
In-Reply-To: <200502202244.j1KMinDD013572@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-02-20 at 17:43, Leonid Grossman wrote:
> Andi,
> This is an interesting idea, we'll play around...
> 
> BTW - does anybody know if it's possible to indicate multiple receive
> packets?
> 
> In other OS drivers we have an option to indicate a "packet train" that got
> received during an interrupt, 

Explain what you mean by "packet train". If you mean a burst of random
packets that just happened to arrive back to back, then it is not
useful. NAPI already does a sufficently great job at processing these by
pulling them off the DMA ring and processing to completion.
OTOH, if you mean a train of packets terminating at exactly the same
location i.e related to the same flow, then this would be useful.
I suspect the later would require extreme intelligence that may not
be suited for your NIC. 
This leaves you with only nicecities of spliting a packet into
header/data which may allow for nice gather-scatter techniques. Remains
to be seen (in other words, proof is in the pudding, make it -
experiment and show that it tastes good).

cheers,
jamal
