From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Fri, 19 Nov 2004 11:16:30 -0200
Message-ID: <419DF22E.5080102@conectiva.com.br>
References: <Xine.LNX.4.44.0411180257300.3144-100000@thoron.boston.redhat.com> <Xine.LNX.4.44.0411180305060.3192-100000@thoron.boston.redhat.com> <20041118084449.Z14339@build.pdx.osdl.net> <419D6746.2020603@blueyonder.co.uk> <20041118231943.B14339@build.pdx.osdl.net> <419DEF98.9040303@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@osdl.org>,
        Ross Kendall Axe <ross.axe@blueyonder.co.uk>,
        James Morris <jmorris@redhat.com>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <419DEF98.9040303@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Arnaldo Carvalho de Melo wrote:
> 
> 
> Chris Wright wrote:
> 
>> * Ross Kendall Axe (ross.axe@blueyonder.co.uk) wrote:
>>
>>> Taking this idea further, couldn't we split unix_dgram_sendmsg into 2 
>>> functions, do_unix_dgram_sendmsg and do_unix_connectionless_sendmsg 
>>> (and similarly for unix_stream_sendmsg), then all we'd need is:
>>>
>>> <pseudocode>
>>> static int do_unix_dgram_sendmsg(...);
>>> static int do_unix_stream_sendmsg(...);
>>> static int do_unix_connectionless_sendmsg(...);
>>> static int do_unix_connectional_sendmsg(...);
>>
>>
>>
>> We could probably break it down to better functions and helpers, but I'm
>> not sure that's quite the breakdown.  That looks to me like an indirect
>> way to pass a flag which is already encoded in the ops and sk_type.
>> At anyrate, for 2.6.10 the changes should be small and obvious.
>> Better refactoring should be left for 2.6.11.
> 
> 
> Hey, go ahead, do the split and please, please use sk->sk_prot, that is
> the way to do the proper split and will allow us to nuke several
> pointers in struct sock (sk_slab, sk_owner for now) :-)
> 
> I have a friend doing this for X.25, will submit his patches as soon
> as we do some more testing and 2.6.10 is out.

Ah, this is the way the inet transport protos have been working for
years, and I've been factoring out the struct proto_ops methods from
TCP into the networking core, look at net/core/stream.c and the
sock_common_ prefixed functions in net/core/sock.c.

- Arnaldo
