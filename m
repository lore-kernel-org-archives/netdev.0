From: jamal <hadi@cyberus.ca>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 4 Jan 2003 14:04:17 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030104135539.C48869@shell.cyberus.ca>
References: <Pine.LNX.4.44.0301042016020.863-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Alexandre Cassen <Alexandre.Cassen@wanadoo.fr>, "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0301042016020.863-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 4 Jan 2003, Julian Anastasov wrote:

>
> 	Hello,
>
> On Sat, 4 Jan 2003, jamal wrote:
>
> >
> > I think hacking the ARP code to do this would be horrible - one way to do
> > it is write a tc module that mungles outgoing ARPs to substitute the src
> > MAC address based on src IP.
>
> 	You can do it with arptables (still not sure how) or with

I havent seen user-space arptables around.

> arprules+iparp:
>
> # send all our requests from VRIP with VMAC
> ip arp add table output from 1.2.3.4 llsrc 00:00:5E:00:01:10
>
> http://www.ssi.bg/~ja/#iparp

I like this concept. This + the patch i posted should resolve the problem
of getting multiple VRIDs on a single interface.
[Although you could do it in a lot less code, maybe 50%, using
some of the tc filter extensions i am working on; also a lot less code
than arptables]

>
> 	But this is not enough for VRRP. For Linux we need a
> way to bind VRIPs to source VMACs or sort of this. I'm cc-ing to Alexandre
> Cassen as he is working on VRRP (http://keepalived.sourceforge.net/).
> I hope he can shed some light on the VRRP needs.
>

I guess there is more than one VRRP implementation on Linux; the one i
played with is from some crazy Frenchman named Jerome Ettiene;->
With two conecpts being addressed i.e patch like that you have +
the patch i posted i dont see any orther reason VRRP to be hindered.

cheers,
jamal
