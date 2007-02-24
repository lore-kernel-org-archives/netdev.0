From: Kristian Evensen <kristrev@ifi.uio.no>
Subject: Re: Copy data from one SKB to another
Date: Sat, 24 Feb 2007 13:32:19 +0200
Message-ID: <45E02243.5010508@ifi.uio.no>
References: <58989.129.240.228.53.1172145587.squirrel@webmail.uio.no>
 <e92e3a770702240137p6c0b31b3r2b7ce0b4042fac4b@mail.gmail.com>
 <45E0193F.5090909@ldb-jab.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: kalash nainwal <nirvana.code@gmail.com>,
	"kristrev@student.matnat.uio.no" <kristrev@student.matnat.uio.no>,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
To: LDB <thesource@ldb-jab.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-reply-to: <45E0193F.5090909@ldb-jab.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LDB wrote:
> kalash nainwal wrote:
>   
>> On 2/22/07, kristrev@student.matnat.uio.no
>> <kristrev@student.matnat.uio.no> wrote:
>>     
>>> Hello,
>>>
>>> I am working on optimizing the TCP-code for a certain type of TCP-stream,
>>> and to make one of my optimizations work I need to copy data from one SKB
>>> (the data field of the skb) to another SKB (data field).
>>>
>>> Currently I am using memcpy, and it does what it is supposed to, but I am
>>> curious as to if there are any other (potentially faster/more efficient)
>>> ways of doing it. I have checked out the skb_add_data (used when you can
>>> copy data from the msg you are sending into the most recent skb added to
>>> the queue), but from what I can understand it only copies from userspace
>>> into kernelspace (whereas I need to copy kernel-kernel).
>>>
>>> Does anyone have any hints, suggestions, solutions or something else they
>>> think might help?
>>>
>>> Thanks,
>>> Kristian
>>>
>>> -
>>>       
>> How about cloning? Is that an option?
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux-net" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>     
>
> skb_clone is an option but you cannot modify any data - correct me if I am wrong.
>
> The other options are pskb_copy and skb_copy used when modifications are
> necessary - correct if I am wrong.
>
> You just have to chose which is appropriate for your specific needs.
>
> LDB
>   
Thank you very much for all your replies. I have spent the day today 
looking into the different clone/copy-functions for skb's, but I cant 
help feeling that they are a bit to advanced for what I want to do. All 
my code is going to do is to copy the skb->data field (the payload) from 
one skb to another (to perform some aggressive bundling, the potentially 
redundant data will be removed when ack occurs).

Since the data copied might be from the retransmission queue, the  
function I see might be useful is the skb_copy function to copy the 
packet that I copy the data from (if it is in the retransmission queue). 
This is also what led to my question about exactly how TCP treats 
acks/sends on the same socket.

My current implementation (using memcopy) copies the data, but some 
weird behaviour occurs (and after days of looking into it I havent found 
the cause). If a dupAck occurs, it rightly sends as many packets from 
the retrans-queue as it is supposed to (and allowed to) do but then 
eveything stops working. Even though the sequence number is correct, I 
only recieves more dupAcks. If someone has experienced similar behaviour 
when working with the TCP-code or have any ideas to what might be wrong, 
please let me know :)

Have a nice weekend!

Thanks,
Kristian
