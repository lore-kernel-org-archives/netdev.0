From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 31 Jan 2005 01:31:43 +0100
Message-ID: <41FD7C6F.3010005@tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>	 <1105019912.2314.20.camel@jzny.localdomain>	 <1105023972.3462.48.camel@tsc-6.cph.tpack.net>	 <1105104757.1046.63.camel@jzny.localdomain>	 <1105111605.3462.101.camel@tsc-6.cph.tpack.net>	 <1105363092.1041.146.camel@jzny.localdomain>	 <1105917038.1091.1041.camel@jzny.localdomain> <41EC3067.6050104@tpack.net>	 <41FD702D.2060403@tpack.net> <1107130177.7847.96.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1107130177.7847.96.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Tommy,
> 
> I wasnt sure why you did:
> 
> dev->qdisc = &noop_qdisc;
> 
> You should probably save the old qdisc in qdisc_sleeping instead
> and restore it on wakeup - otherwise you always end with default qdisc.

I think normally we will have qdisc == qdisc_sleeping. At least this
is how I read the code in dev_graft_qdisc(). When can they differ?

> check_carrier should probably just call dev_activate which does all you
> wanted, no?

I copied the logic from dev_deactivate(), but I didn't want to include
the waiting parts, since this is not in process context. OK?

-Tommy
