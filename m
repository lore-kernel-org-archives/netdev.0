From: rick jones <rick.jones2@hp.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 12:19:35 -0800
Message-ID: <86de38db09518ced8865af09cd79c064@hp.com>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net> <20050212143105.GB27456@yakov.inr.ac.ru>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, romieu@fr.zoreil.com, hubert.tonneau@fullpliant.org,
        shemminger@osdl.org
In-Reply-To: <20050212143105.GB27456@yakov.inr.ac.ru>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Feb 12, 2005, at 6:31 AM, Alexey Kuznetsov wrote:

> Hello!
>
>>> In some cases at least if the sender does not completely fill cwnd 
>>> the
>>> ACKs will  be delayed.  And IIRC under 2.6.10 with TSO enabled, the
>>> sender does not always  fill cwnd.
>>
>> At a maximum, "1/tcp_tso_win_divisor" of the cwnd will ever be left
>> empty.
>>
>> By default, this is 1/8 of the cwnd.
>
> In any case, receiver cannot know sender cwnd, so that "fill" or "not 
> fill"
> is is not a question.

How is that?  Isn't cwnd based on the ACKs the sender receives from the 
receiver?

> What is broken in that implementation is that it does not feel slow 
> start.
> ACK avoidance while slow start is certain disaster. Currrent theory is 
> that
> MacOS X thinks that we do not do slow start.

Actually, it may think slow start is being done - there was enough 
small packet back and forth on the connection before the "heavy 
transfer" to get cwnd opened - I just didn't quote that in the "cooked" 
output.  All the stacks with ACK avoidance with which I am familiar do 
not make the assumption that the sender is not doing slow-start.  They 
make sure to send enough ACKs at the beginning (or after packet loss) 
to allow the sender's cwnd to grow.

rick jones
wisdom teeth are impacted, people are affected by the effects of events
