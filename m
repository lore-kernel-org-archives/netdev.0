From: devnetfs <devnetfs@yahoo.com>
Subject: fragmentation
Date: Sat, 1 Feb 2003 10:22:35 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030201182235.89076.qmail@web20422.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I have a skb whose data I want to fragment into fixed size
chunks with each fragment having its own (fixed size) header.

What is the fastest way to do this, with minimal copying of data
around? The easiest approach looks to be:

1. allocated a *new* skb of size=header_size+fragement_size
2. *copy* part of data from my original skb into this new pkt
3. setup the header in the fragmented-packet
4. xmit this sk_buff (dev_queue_xmit)

What I dont like is the *new* and (extra) *copy* part. As my original
skb in in the kernel itself an additional copy (of fragment-size)
before xmit seems wasteful to me.

Is it possible to allocate buffer-space for just the header and then
have pointers into the original skb for the fragement data, avoiding
the extra *copy* of the fragment-data.

So the question(s) are:

[1] can I submit a packet (a sk_buff)to low level device (using
    dev_queue_xmit()) that has its buffer/data in discontinuous 
    blocks in the kernel -- some kind of iovec. 
    And if the network device supports DMA gather -- this would 
    make the xmit path very fast. right?
OR
[2] can I submit a chain of sk_buff's that need to be xmited as ONE
    ether frame to dev_queue_xmit()?
OR
[2] such a chaining is not very useful and the above approach 
    (steps 1-4) is ok.

[btw this data is being generated in the kernel and sent over ether]

Any insights or possible solutions would be helpful.

Thanks,
A.

ps: I've just subscribed to netdev, so not sure if I will get the reply
to this mail. So please Cc: me the reply -- thanks.

__________________________________________________
Do you Yahoo!?
Yahoo! Mail Plus - Powerful. Affordable. Sign up now.
http://mailplus.yahoo.com
