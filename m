From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Mon, 13 Jan 2003 16:56:56 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0301131651170.1861-100000@dyn9-47-18-98.beaverton.ibm.com>
References: <1042498998.2610.8.camel@devil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>, <kuznet@ms2.inr.ac.ru>,
   Jon Grimm <jgrimm2@us.ibm.com>, <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mika Liljeberg <mika.liljeberg@welho.com>
In-Reply-To: <1042498998.2610.8.camel@devil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 14 Jan 2003, Mika Liljeberg wrote:

> Hi,
> 
> I know this is not what the SCTP spec recommends with IPv4, but what
> prevents you from just fragmenting the IP packets at the source and
> setting the DF bit on each fragment (assuming you can't just repackage
> the data chunks)? This would be equivalent to the IPv6 behaviour and
> would keep PMTUD working perfectly.

SCTP does segment the packets based on the current PMTU and sets DF bit to not
allowing IP fragmentation. The problem occurs when the PMTU shrinks and there
are outstanding segmented packets which need to be retransmitted. We cannot
re-segment these packets, but would like IP to fragment them by not setting
DF bit. 

> 
> With IPv6 you don't have a DF bit to control, so you have only two
> options. Either use a maximum chunk size smaller than 1280, or fragment
> at the source.
> 
> Regards,
> 
> 	MikaL
> 
> 
> 
