From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Mon, 03 Mar 2003 14:11:07 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E63A8CB.2090307@nortelnetworks.com>
References: <3E638C51.2000904@nortelnetworks.com>	<20030303.085504.105424448.davem@redhat.com>	<3E6399F1.10303@nortelnetworks.com> <20030303.095641.87696857.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: terje.eggestad@scali.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Chris Friesen <cfriesen@nortelnetworks.com>
>    Date: Mon, 03 Mar 2003 13:07:45 -0500
>    
>    Suppose I have a process that waits on UDP packets, the unified local 
>    IPC that we're discussing, other unix sockets, and stdin.  It's awfully 
>    nice if the local IPC can be handled using the same select/poll 
>    mechanism as all the other messaging.
> 
> So use UDP, you still haven't backed up your performance
> claims.  Experiment, set the SO_NO_CHECK socket option to
> "1" and see if that makes a difference performance wise
> for local clients.

I did provide numbers for UDP latency, which is more critical for my own 
application since most messages fit within a single packet.  I haven't 
done UDP bandwidth testing--I need to check how lmbench did it for the 
unix socket and do the same for UDP.  Local TCP was far slower than unix 
sockets though.

> But if performance is "so important", then you shouldn't really be
> shying away from the shared memory suggestion and nothing is going to
> top that (it eliminates all the copies, using flat out AF_UNIX over
> UDP only truly eliminates some header processing, nothing more, the
> copies are still there with AF_UNIX).

Yes, I realize that the receiver still has to do a copy.  With large 
messages this could be an issue.  With small messages, I had assumed 
that the cost of a recv() wouldn't be that much worse than the cost of 
the sender doing a kill() to alert the receiver that a message is 
waiting.  Maybe I was wrong.

It might be interesting to try a combination of sysV msg queue and 
signals to see how it stacks up.  Project for tonight.

Chris





-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
