From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: 15 Sep 2003 08:12:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063627928.1075.66.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
	 <3F60CA6D.9090503@pobox.com> <3F60D0F3.8080006@candelatech.com>
	 <20030911131219.0ab8dfdd.davem@redhat.com>
	 <3F60DDCC.5020906@candelatech.com>
	 <20030911140746.4f0384a1.davem@redhat.com>
	 <3F60E947.4090005@candelatech.com>
	 <20030911142906.74d9dfe5.davem@redhat.com>
	 <3F60F3F7.6090203@candelatech.com>
	 <20030911160252.6cd6c07d.davem@redhat.com>
	 <3F6103BB.5030706@candelatech.com>
	 <1063330463.1028.8.camel@jzny.localdomain>
	 <20030912204947.5267e3aa.davem@redhat.com>
	 <16227.1284.893748.365713@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, greearb@candelatech.com,
   jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16227.1284.893748.365713@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-09-13 at 07:52, Robert Olsson wrote:

>  > 
>  > I spoke with Alexey once about this, actually tx_queue_len can
>  > be arbitrarily large but it should be reasonable nonetheless.
>  > 
>  > Our preliminary conclusions were that values of 1000 for 100Mbit and
>  > faster were probably appropriate.  Maybe something larger for 1Gbit,
>  > who knows.

If you recall we saw that even for the gent who was trying to do 100K
TCP sockets on a 4 way SMP, 1000 was sufficient and no packets were
dropped.

>  > 
>  > We also determined that the only connection between TX descriptor
>  > ring size and dev->tx_queue_len was that the latter should be large
>  > enough to handle, at a minimum, the amount of pending TX descriptor
>  > ACKs that can be pending considering mitigation et al.
>  > 
>  > So if TX irq mitigation can defer up to N TX descriptor completions
>  > then dev->tx_queue_len must be at least that large.
>  > 
>  > Back to the main topic, maybe we should set dev->tx_queue_len to
>  > 1000 by default for all ethernet devices.
> 
>  Hello!
> 
>  Yes sounds like adequate setting for GIGE. This is what use for production
>  and lab but rather than increasing dev->tx_queue_len to 1000 we replace the 
>  pfifo_fast with the pfifo qdisc w. setting a qlen of 1000.
> 

I think this may not be good for the reason of QoS. You want BGP packets
to be given priority over ftp. A single queue kills that.
The current default 3 band queue is good enough, the only challenge
being noone sees stats for it. I have a patch for the kernel at:
http://www.cyberus.ca/~hadi/patches/restore.pfifo.kernel
and for tc at:
http://www.cyberus.ca/~hadi/patches/restore.pfifo.tc

cheers,
jamal
