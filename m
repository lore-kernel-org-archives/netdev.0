From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] select appropriate skb size in tcp_sendmsg when TSO is
 used
Date: Thu, 28 Oct 2004 00:16:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418072A1.9020509@pobox.com>
References: <OF96546AB5.ACE12043-ONC1256F33.0027BC6B-C1256F33.002D4A6E@de.ibm.com>	<E1CKE5P-0005SP-00@gondolin.me.apana.org.au>	<20041020163510.6d13e9c7.davem@davemloft.net>	<20041026111912.GA18095@gondor.apana.org.au>	<20041026235126.GA4733@gondor.apana.org.au>	<417EE3BB.6040902@pobox.com>	<20041027000724.GA4869@gondor.apana.org.au>	<20041027001531.GA29973@havoc.gtf.org>	<20041027002209.GA5002@gondor.apana.org.au> <20041026175553.55a1b72d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, thomas.spatzier@de.ibm.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041026175553.55a1b72d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 27 Oct 2004 10:22:09 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> 
>>On Tue, Oct 26, 2004 at 08:15:31PM -0400, Jeff Garzik wrote:
>>
>>>>IMHO it is valid to disable SG without disabling checksums, no?
>>>
>>>It's useless:  The packet header is always in a separate memory
>>>location from the packet data, when using zerocopy sendfile(2).
>>>
>>>When not using zerocopy sendfile, you are copying the data _anyway_.
>>
>>I'm fine with adding this check.  However I think that belongs in
>>another patch since we don't check that in register_netdev currently.
>>
>>Dave, what do you think?
> 
> 
> I believe that allowing TX csum support without SG _is_
> useful even though it is not _effective_.
> 
> It is quite desirable for a driver author to be able to
> test out his TX csum offload support first, then add
> SG support next.  Similarly, if a driver author suspects
> some issues with either SG or TX csum support, he can
> better isolate the problem if we allow this.
> 
> Jeff do you agree?


<shrug>  it's never used that way in practice AFAIK, only used by 
confused sysadmins :)

I won't object if you preserve the behavior, but I still don't see much 
value in allowing it.

	Jeff
