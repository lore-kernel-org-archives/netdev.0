From: nick black <dank@qemfd.net>
Subject: Re: Transparent Proxying
Date: Wed, 11 Aug 2004 20:31:34 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnchl0h5.7vo.dank@hoist.localnet>
References: <20040804032756.GA2388@gondor.apana.org.au>
Reply-To: dank@reflexsecurity.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2004-08-04, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> I looked around and found the TPROXY patch which is part of pom-ng.
> It is capable of providing the information I need via a getsockopt()
> call.

I had to do something similar recently.  While the entirety of TPROXY
has not been accepted from what I could tell (particularly non-local
binding supplying a routing context), the SO_ORIGINAL_DST sockopt
referenced while searching for it works under at least late 2.4:

struct sockaddr_in daddr;
socklen_t slen;

memset(&daddr,0,sizeof(daddr));
daddr.sin_family = AF_INET;
slen = sizeof(daddr);
if(getsockopt(accepted_sd,SOL_IP,SO_ORIGINAL_DST,&daddr,&slen)){
	close(accepted_sd);
	return -1;
}

-- 
nick black                  "np:  the class of dashed hopes and idle dreams."
free hearts, free foreheads -- you and i are old; old age hath yet his honour
and his toil; death closes all: but something ere the end, some work of noble
note, may yet be done, not unbecoming men that strove with gods.   (tennyson)
