From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 15:40:20 -0800
Message-ID: <420D4264.6030400@hp.com>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <420D3B17.3040506@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Tonneau <hubert.tonneau@fullpliant.org>, shemminger@osdl.org,
        romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru
To: netdev@oss.sgi.com
In-Reply-To: <420D3B17.3040506@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Er, how is this compliant with 2581 (yes, I know, it's only a SHOULD, not a
> MUST)  - an ACK should be generated for at least every second full-sized
> segment received? Don't see that happening. In many cases it's receiving
> quite a few more packets. It should not be waiting for the delayed ack timer
> to go off, surely?

Certainly it would make for an interesting disuscion.  Indeed it is a
SHOULD which leaves-open the door to compliance of other ACK policies.  Those 
might result in an ACK for more than two segments, or even an ACK for fewer than 
two segments, and there are folks in either camp/faction/sect/pick your favorite 
term.

I would say that it is still compliant with 2581.  The must there is that no 
matter what, an ACK must be generated within 500 milliseconds.

I suspect that had a full cwnd's worth of data been sent there would have been 
no lengthy delay in ACKs even with fewer than ACK-every-other.  I suspect that 
had TSO been disabled the full cwnd would have been sent and these delayed ACKs 
would not have happened and the transfer speed would have been happiness and joy.

FWIW, as the industry has added features such as CKO (ChecKsum Offload), 
copy-avoidance, and now TSO, the pie chart of time spent has been shifting more 
and more to ACK processing.  If we go back far enough, the writeups talk about 
how delayed ACK to increase ACK piggybacking was added in the first place - 
specifically (IIRC) for the purpose of minimizing ACK overhead.

rick jones

BTW, I'd be happy to trim emails that are already on netdev to avoid message 
duplications, is netdev a "closed" list?
