From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Re: Poor gige performance with 2.4.20-pre*
Date: Sun, 29 Sep 2002 13:22:10 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209291922.g8TJMA312403@vindaloo.ras.ucalgary.ca>
References: <200209282257.g8SMvta32527@vindaloo.ras.ucalgary.ca>
	<3D966656.7040205@candelatech.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D966656.7040205@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear writes:
> Richard Gooch wrote:
> >   Hi, all. For a while now I've noticed poor performance with gige
> > cards under 2.4.19 and 2.4.20-pre*. At first I thought it was because
> > of the cheap-ass Addtron cards I bought (these use the ns83820 chip).
> > But now that the Intel E1000 cards are pretty cheap too, I've grabbed
> > a couple (part number: PWLA8390MT) and see the same problem. In fact,
> > the E1000 cards are no better than the Addtron cards. I'm using the
> > D-Link DGS-1008T 8-port gige switch. MTU=1500 bytes.
>
> Try setting the TxDescriptors=4096 RxDescriptors=1024 when loading the
> e1000 module, that helps tremendously when using smaller packets.

Didn't help at all. Just to summarise, I've got:
options e1000 TxDescriptors=4096 RxDescriptors=1024
net.ipv4.tcp_rmem = 262144 262144 262144
net.ipv4.tcp_wmem = 262144 262144 262144
MTU=1500

I'm doing read(2)/write(2) to/from a user-space buffer over a TCP
socket with 256 KiB buffer size.

Is the E1000 supposed to have hardware interrupt mitigation (thus
avoiding the need for NAPI)?

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
