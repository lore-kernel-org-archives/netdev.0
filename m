From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 02:31:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414E24E4.1020104@eurodev.net>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <20040919120730.GA6005@gondor.apana.org.au> <414DF111.3080409@eurodev.net> <20040919215328.GA9573@gondor.apana.org.au> <414E0CE6.107@eurodev.net> <20040919234445.GC10124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, jamal <hadi@cyberus.ca>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040919234445.GC10124@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu wrote:

>On Mon, Sep 20, 2004 at 12:49:10AM +0200, Pablo Neira wrote:
>  
>
>>Sorry, if i repeat things, I'm not willing to be annoying, just clarifying.
>>    
>>
>
>You're alright.  We're on the same side :)
>  
>

that's fine :)

>There is no point for the kernel to wait at all.  For unicast sockets
>used for sending commands to the kernel, you should never get overruns
>if you are reading your responses correctly and have set the queue size
>correctly.
>  
>

sure, not for commands. When I talk about netlink sockets, I'm not 
focused on commands because what they do currently is quite enough for 
them I think. I know that commands are the main application of netlink 
sockets but there are many others.

>>b) A module needs to send a lot of information from kernel space to user 
>>space, if buffer gets full quickly, buffer overruns and 
>>netlink_unicast/broadcast never wait, so they drop packets.
>>    
>>
>
>I agree that this may be a problem for some, but I don't see how your
>patch addresses it.  For the case of ip_queue the kernel simply cannot
>wait since it just creates a queue through the backdoor.  You might as
>well just increase your receive queue length.
>  
>

I agree, ip_queue case is kind of complex. Well, think about a logging 
tool for packets in kernel space that sends messages via netlink when a 
packet matches a condition. Now, we receive 300 packets in a very very 
short period of time (with the default buffer size) and after that 
everything' gets calm again, that is, there's nothing to send to user space.

In that case, netlink buffer will surely overrun, so those 300 messages 
will be drop because kernel didn't wait a bit. This is what happens now, 
I can reproduce this with my tool.

Well, if system work load is high (in term of sending netlink messages), 
we don't have too many things to do...

regards,
Pablo
