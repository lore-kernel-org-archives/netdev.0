From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: Submission for S2io 10GbE driver
Date: Mon, 26 Jan 2004 21:32:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001801c3e497$010671a0$0400a8c0@S2IOtech.com>
References: <20040123162134.79c67ed5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Stephen Hemminger'" <shemminger@osdl.org>, "'Andi Kleen'" <ak@suse.de>
In-Reply-To: <20040123162134.79c67ed5.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Stephen,
Below are responses from our developer.

Thanks for the input, Leonid

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@osdl.org] 
> Sent: Friday, January 23, 2004 4:22 PM
> To: Andi Kleen
> Cc: Leonid Grossman; netdev@oss.sgi.com
> Subject: Re: Submission for S2io 10GbE driver
> 
> 
> Noticed the setup loopback test seems to register for a 
> packet type and then forget to unregister that type! 

The packet type gets unregistered at the end of the test in the
'reset_loopback'
function through the system call 'dev_remove_pack()'

> 
> Also nothing really restricts the packet type to only coming 
> in on the expected interface; therefore if someone sends the 
> same packet in over another interface, then sp->loop_pkt_cnt 
> will end up incrementing some other drivers private data 
> structure *bad*.

Correct, that's why in the s2io.c source where I define the
packet_type's protocol value
through the Macro 'ETH_LOOP_TEST_TYPE' there's a ToDo to obtain a
private protocol ID. 
This way no app in the real world can ever pass a frame with that T/L
field in the packet.
Also, the problem can only happen during the 3 second duration when this
test is in progress.

> 
> IMHO the whole loopback test frame stuff seems like something 
> in a test bed driver, not production code.

The loopback test is there as a part of the ethtool's diagnostic option.


There are pros and cons of having the test in there I guess, anyone else
has an opinion on this?

Do other net drivers normally support loopback and other diag tests as a
part of the ethtool support,
or they provide little/no support for the option and ship a standalone
diag program instead?

Thanks, Leonid

> 
