From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: 25 Mar 2005 20:11:00 -0500
Message-ID: <1111799460.1089.785.camel@jzny.localdomain>
References: <1111795927.1089.749.camel@jzny.localdomain>
	 <20050326003058.GA22930@gondor.apana.org.au>
	 <1111798470.1090.774.camel@jzny.localdomain>
	 <20050326005855.GA23533@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326005855.GA23533@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 19:58, Herbert Xu wrote:
> On Fri, Mar 25, 2005 at 07:54:31PM -0500, jamal wrote:
> >
> > It seems that we dont support any acquires from userspace to kernel
> 
> I haven't checked af_key but netlink does support that.  All you have
> to do is send messages to the correct multicast group.
> 
> Of course whether any of the KMs actually deal with it is a different
> story :)

What i have seen being described is as follows:

user space app --> kernel
  acquire with all necessary parameters
kernel --> XFRMGRP_ACQURE
  acquire as it would right now with an outbound packet
some KM -->kernel
  SA ADD/UPD
Kernel ---> XFRMGRP_SA (we are working on this, app hears announce) 
  SA ADD/UPD event 

now the SA is in the kernel user space app could point to it via
some SPD like classifier. 

cheers,
jamal
