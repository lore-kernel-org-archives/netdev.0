From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: 30 Oct 2004 15:10:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099163419.1039.97.camel@jzny.localdomain>
References: <20041030013700.GA21540@lists.us.dell.com>
	 <E1CNiOT-0008GU-00@gondolin.me.apana.org.au>
	 <20041030030936.GA25102@lists.us.dell.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
In-Reply-To: <20041030030936.GA25102@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-29 at 23:09, Matt Domsch wrote:
> On Sat, Oct 30, 2004 at 11:51:01AM +1000, Herbert Xu wrote:
> > > s/dev_addr/addr_len in the comments above, that's the field we care
> > > about being non-zero.
> > 
> > This still doesn't make sense.  What if dev->addr_len is less than the
> > size of the buffer? The caller has to know what the length is anyway.
> 
> Ahh, indeed.  net-snmp has hard-coded the number 6 or uses the
> definition of IFHWADDRLEN (from include/linux/if.h, a copy of which is
> in /usr/include/linux/if.h of course) in several places for this.

fix the net-snmp code. The addr_len is dependent on the device type.
6 is good for ethernet but may not equate for others.

Having said that i think we should somehow signal that info to user
space. perhaps returning -EINVAL in the case the L2 address is 0?
EINVAL will break a few apps and make them puke as opposed to silently
returning something wrong.

cheers,
jamal
