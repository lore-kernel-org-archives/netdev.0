From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 14:46:24 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0402021443570.6508-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.58.0402021319440.5347@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.58.0402021319440.5347@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Steve Hill wrote:

> I turned on the debugging code and got:
>
> ----
> ip_conntrack_in: new packet for ce8fae40
> Altering reply tuple of ce8fae40 to tuple c0357de4: 1 172.16.0.1:5438 ->
> 172.17.0.1:0
> Altering reply tuple of ce8fae40 to tuple c0357cdc: 1 172.16.0.1:5438 ->
> 172.17.0.1:0
> Confirming conntrack ce8fae40
> conntrack_put ce8faebc 4
> conntrack_put ce8faebc 3
> clean_from_lists(ce8fae40)
> remove_expectations(ce8fae40)
> conntrack_put ce8faeb4 3
> conntrack_put ce8faec0 4
> conntrack_put ce8faec0 3
> ----
>
> (the conntrack_put debugging was added by me to the nf_conntrack_put()
> function - it shows the pointer to nfct and the usage count).
>
> If it send a small packet through, which won't be fragmented I get:
>
> ----
> ip_conntrack_in: new packet for ce8fa080
> Altering reply tuple of ce8fa080 to tuple c0357de4: 1 172.16.0.1:39486 ->
> 172.17.0.1:0
> Altering reply tuple of ce8fa080 to tuple c0357d20: 1 172.16.0.1:39486 ->
> 172.17.0.1:0
> Confirming conntrack ce8fa080
> conntrack_put ce8fa0fc 2
> clean_from_lists(ce8fa080)
> remove_expectations(ce8fa080)
> conntrack_put ce8fa0f4 2
> conntrack_put ce8fa100 1
> destroy_conntrack(ce8fa080)
> destroy_conntrack: returning ct=ce8fa080 to slab
> ----

You convinced me: something is really fishy. I fire up debugging and
checking.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
