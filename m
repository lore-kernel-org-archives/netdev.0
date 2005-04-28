From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Wed, 27 Apr 2005 22:39:40 -0400
Message-ID: <1114655980.7663.76.camel@localhost.localdomain>
References: <1114654284.7663.50.camel@localhost.localdomain>
	 <20050428021426.GA23415@gondor.apana.org.au>
	 <1114655014.7663.61.camel@localhost.localdomain>
	 <20050428022549.GA23556@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428022549.GA23556@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 12:25 +1000, Herbert Xu wrote:
> On Wed, Apr 27, 2005 at 10:23:34PM -0400, jamal wrote:
> > 
> > well, i think it is a bug that indices are being ignored by the kernel.
> > To demonstrate:
> > Add a rule with index 100;
> > now try to delete or get by index.
> 
> But your patch has nothing to do with this.  You were changing
> id & 7 to dir.  Because the lower bits of index is set from the
> direction, this is a no-op.

The patch allows to walk all policies in the direction until a match to
the index is found.
It removes the assumption that theres a formula to compute indices
(which is fine if used by the kernel when I specify no index).

------------
jdev10:~# ip x policy add dir in index 102 priority 10 src 11.0.0.10 dst
11.0.0.2

jdev10:~# ip x p get dir in index 102
src 11.0.0.10/32 dst 11.0.0.2/32
        dir in priority 10
jdev10:~# ip -s x p ls
src 11.0.0.10/32 dst 11.0.0.2/32 uid 0
        dir in action allow index 102 priority 10 share any flag
0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2005-04-28 02:45:10 use -
-----

That would never work without those two patches.

cheers,
jamal
