From: jamal <hadi@cyberus.ca>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: 03 Apr 2005 21:58:31 -0400
Message-ID: <1112579911.1088.416.camel@jzny.localdomain>
References: <20050401042106.GA27762@gondor.apana.org.au>
	 <1112353398.1096.116.camel@jzny.localdomain>
	 <20050401114258.GA2932@gondor.apana.org.au>
	 <1112358278.1096.160.camel@jzny.localdomain>
	 <20050401123554.GA3468@gondor.apana.org.au>
	 <1112403845.1088.14.camel@jzny.localdomain>
	 <20050402012813.GA24575@gondor.apana.org.au>
	 <1112406164.1088.54.camel@jzny.localdomain>
	 <20050402014619.GB24861@gondor.apana.org.au>
	 <1112469601.1088.173.camel@jzny.localdomain>
	 <20050404010114.GA16839@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404010114.GA16839@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-03 at 21:01, Herbert Xu wrote:
> On Sat, Apr 02, 2005 at 02:20:01PM -0500, jamal wrote:
> > 
> > 1) Weve discussed this before Herbert and i think you misspoke that
> > pfkey delivers to all listerners.
> > 
> > pfkey Add/del/upd now really do tell all processes about what happened.
> > Before pfkey would skip the originating process. So far this doesnt seem
> > to be an issue in the basic testing.
> 
> Are you sure? Previously they did BROADCAST_ALL which goes to everyone
> including the sender.
> 

Yes, he key is in the sk parameter to the broadcast. if a NULL is passed
then all listeners are told. Else the passed sk is excluded.

> > 2) I ended adding a policy_notify to the pfkey manager to make the code
> > generic. Interesting thing is i dont think pfkey knows what to do with 
> > policy expiration or i am misreading the code.
> 
> That's right, pfkey never had policy expire messages.  In general,
> anything to do with policies cannot be done portably in pfkey since
> the RFC only specified the SA operations.
> 

Well, hopefully whoever defined that pfkey carries policies as well will
have to worry about this in the future. I will just leave teh hook but
remove the printk.

cheers,
jamal
