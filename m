From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] tcf_bind_filter failure handling
Date: Mon, 13 Dec 2004 20:12:40 +0100
Message-ID: <41BDE9A8.9080505@trash.net>
References: <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch> <41917330.6090002@trash.net> <20041212175736.GA8493@postel.suug.ch> <41BC8819.7040501@trash.net> <20041213165302.GE8493@postel.suug.ch> <41BDDB5A.9000907@trash.net> <20041213185203.GF8493@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041213185203.GF8493@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>* Patrick McHardy <41BDDB5A.9000907@trash.net> 2004-12-13 19:11
>  
>
>>You should just fix tcindex not to care about errors in tcf_bind_filter.
>>bind_tcf already locks the class. Some qdiscs (like prio) map bind_filter
>>to get, but others (HTB, HFSC, CBQ) use a seperate counter because it is
>>legal to end up with a refcnt > 0 after delete. When a class with filters
>>pointing to it is tried to destroy they return -EBUSY, which can't be done
>>by looking at the refcnt.
>>    
>>
>
>Little misunderstanding here. I'm not aiming at replacing tcf_bind_filter
>with get.  My question is rather whether to regard tcf_bind_filter not setting
>tcf_result->class as an error or ignore it. 
>
>I'm all for ignoring it in tcindex, it requires some changes because
>it checks tcf_result.class field to see if hash bucket is non-empty if
>perfect hash is used but is not a problem at all.
>
>The tcf_class_get/put would be required to ensure proper locking during
>validation of parameters if validating the classid being last before
>changing things doesn't make sense due to the need to undo expensive
>operations required before binding.
>
>I will fix tcindex, since you also agree on simply ignoring it and regard
>the binding as an ptional locking and performance increase possibility
>given to userspace.
>
Yes, it should be ignored, otherwise you can't point a filter to a class
you will add later.

Regards
Patrick
