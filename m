From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: hfsc and huge set of rules
Date: Sun, 01 Aug 2004 19:56:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410D2EB4.1060205@trash.net>
References: <Pine.LNX.4.33.0407301752250.1421-100000@devix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, netdev@oss.sgi.com,
        tomasz.paszkowski@e-wro.pl
Return-path: <netdev-bounce@oss.sgi.com>
To: devik <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.33.0407301752250.1421-100000@devix>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

devik wrote:

>Also IIRC class lookup is done before each remove. With
>hashing size a few tens of buckets the complexity
>starts to be very near to O(n^2).
>  
>
I think the hash size of HTB, HFSC and CBQ should be increased,
the hash function performs well even with 2^16. With HFSC using
many classes doesn't scale well right now, but with the rbtree patches
it will.

Regards
Patrick

>devik
>
>On Fri, 30 Jul 2004, Patrick McHardy wrote:
>
>  
>
>>David S. Miller wrote:
>>    
>>
>>>Looks like qdisc destruction has some expensive algorithms.
>>>Any quick ideas about the root culprit at least in the hfsc
>>>case?  He says htb does it too.
>>>      
>>>
>>hfsc_destroy_qdisc takes O(n) time wrt. the number of classes,
>>but 5-6 seconds is still long. If all these classes contain inner
>>qdiscs other than the default, I guess removing the classes from
>>dev->qdisc_list in qdisc_destroy takes up most of the time, with
>>n O(n) operations. The __qdisc_destroy rcu callback also calls
>>reset before destroy, I don't know any qdisc where this is really
>>neccessary. Without inner qdiscs, I need to see the script first to
>>judge what's going wrong. Tomasz ?
>>    
>>
