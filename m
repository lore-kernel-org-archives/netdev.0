From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Tue, 22 Feb 2005 14:17:35 -0800
Message-ID: <200502222218.j1MMIVDD007619@guinness.s2io.com>
References: <20050222214345.GA51890@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Stephen Hemminger'" <shemminger@osdl.org>, <hadi@cyberus.ca>,
        "'rick jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>,
        "'Alex Aizman'" <alex@neterion.com>
To: "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>
In-Reply-To: <20050222214345.GA51890@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Andi Kleen [mailto:ak@muc.de] 
> Sent: Tuesday, February 22, 2005 1:44 PM
> To: Leonid Grossman
> Cc: 'Stephen Hemminger'; hadi@cyberus.ca; 'rick jones'; 
> netdev@oss.sgi.com; 'Alex Aizman'
> Subject: Re: Intel and TOE in the news
> 
> > TSO case is probably different - TSO hardware just sets PSH on the 
> > last fragment only (and only if the flag was set on the 
> original large 
> > tx packet). Receiver doesn't really know if the sender is 
> TSO-capable 
> > or not and will ACK the same way - will it not?
> > Anyway, with LRO we do change rx packet count so affecting parts of 
> > TCP that depend on packet count is indeed a concern; I guess we'll 
> > find out soon enough whether there are real issues with the 
> approach 
> > :-)
> 
> Linux doesn't depend on packet count; it keeps an estimate 
> called rcv_mss about the biggest seen packet size and acks 
> every 2*rcv_mss worth of data.
> 
> Your scheme would likely result in acking every two of your 
> large packets as soon as the connection is out of "quickack" 
> mode. So there would be on wire differences. 

Sounds good, thanks! We should be OK then.
Leonid
> 
> > > Linux TCP RX path didn't care about PSH last time I checked. 
> 
> Actually it does for measuring the rcv_mss for very small MTUs. 
> Shouldn't matter in practice though.
> 
> -Andi
> 
