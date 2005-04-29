From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Fri, 29 Apr 2005 08:51:44 -0400
Message-ID: <1114779104.7800.22.camel@localhost.localdomain>
References: <1114654284.7663.50.camel@localhost.localdomain>
	 <20050428021426.GA23415@gondor.apana.org.au>
	 <1114655014.7663.61.camel@localhost.localdomain>
	 <20050428022549.GA23556@gondor.apana.org.au>
	 <1114655980.7663.76.camel@localhost.localdomain>
	 <20050428024253.GA23695@gondor.apana.org.au>
	 <1114656932.7663.88.camel@localhost.localdomain>
	 <20050428030325.GB23823@gondor.apana.org.au>
	 <1114658657.7663.110.camel@localhost.localdomain>
	 <1114698033.7663.197.camel@localhost.localdomain>
	 <20050428231154.GA14215@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428231154.GA14215@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-29-04 at 09:11 +1000, Herbert Xu wrote:

> Now that you are allowing the user to set the index, this excl check
> really needs to go.  Otherwise the user can add two policies with
> the same index.

Agreed.

> 
> You also still need to solve the problem that you may need to
> delete two policies if one matches the index while the other matches
> the selector (or selector plus priority if you do that).
> 

Ok, this bit is tricky...  that is unless we disallowed it from
happening in the first place maybe

i.e something along the lines of:

delp1 = find by index
delp2 = find by selector
if delp1 && delp2 and delp1 != delp2
return -EINVAL

// so far good. check the add case
if delp1 || delp2 and excl
return -EEXIST
        
do the insert here based on priority ..

Thoughts?

cheers,
jamal
