From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Wed, 4 Jan 2012 10:03:49 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1201041000150.925@blackhole.kfki.hu>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <alpine.DEB.2.00.1201040922020.925@blackhole.kfki.hu> <201201040949.54985.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201201040949.54985.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jan 2012, Hans Schillstrom wrote:

> On Wednesday 04 January 2012 09:28:05 Jozsef Kadlecsik wrote:
> > 
> > On Wed, 4 Jan 2012, Hans Schillstrom wrote:
> > 
> > > In some cases it not desirable to have auto defrag.
> > > Ex. in a cluster where packets can arrive on different blades.
> > > In that case it is possible to use containers (LXC) and send
> > > all fragments to one place where defrag is enabled.
> > > 
> > > This patch makes it possible to turn off the defrag per network name space,
> > > by setting net.netfilter.nf_conntrack_nodefrag to 1.
> > > Both IPv4 and IPv6 is effected by this sysctl.
> > > Default is 0 which is defrag.
> > 
> > Conntrack assumes that the packets are defragmented and will drop any 
> > unfragmented one. So your patch results packet drops.
> 
> Hmmm, more work...
> > 
> > Also, if you want to disable defragmentation then why don't you simply 
> > "mark" the packets with the NOTRACK target?
> 
> I don't think that will work since NF_IP_PRI_CONNTRACK_DEFRAG is -400

Then change NF_IP_PRI_RAW so that it precedes NF_IP_PRI_CONNTRACK_DEFRAG. 
The raw table should be made possible to completely override conntack and 
defrag is implicit part of the latter.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
