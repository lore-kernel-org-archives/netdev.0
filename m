From: Julian Anastasov <ja@ssi.bg>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 4 Jan 2003 20:36:38 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301042016020.863-100000@u.domain.uli>
References: <20030104122619.R48869@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Alexandre Cassen <Alexandre.Cassen@wanadoo.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030104122619.R48869@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sat, 4 Jan 2003, jamal wrote:

> > > And btw, i didnt even open up the whole can of worms - we also need to
> > > respond back with proper MAC addresses to ARPs and packets sourced with
> > > specific virtual router IPs. This is a seprate problem.
> >
> > Yup, a whole can of worms if you want it to be a general feature handled
> > by the kernel...
> >
>
> I think hacking the ARP code to do this would be horrible - one way to do
> it is write a tc module that mungles outgoing ARPs to substitute the src
> MAC address based on src IP.

	You can do it with arptables (still not sure how) or with 
arprules+iparp:

# send all our requests from VRIP with VMAC
ip arp add table output from 1.2.3.4 llsrc 00:00:5E:00:01:10

http://www.ssi.bg/~ja/#iparp

	But this is not enough for VRRP. For Linux we need a
way to bind VRIPs to source VMACs or sort of this. I'm cc-ing to Alexandre
Cassen as he is working on VRRP (http://keepalived.sourceforge.net/).
I hope he can shed some light on the VRRP needs.

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
