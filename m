From: Angelo Dell'Aera <buffer@antifork.org>
Subject: Re: TCP congestion control article
Date: Tue, 29 Jun 2004 20:34:18 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040629203418.0a844a5b.buffer@antifork.org>
References: <20040625123953.1d42b556.buffer@antifork.org>
	<20040625091158.2e84ed3a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040625091158.2e84ed3a.davem@redhat.com>
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Fri, 25 Jun 2004 09:11:58 -0700
"David S. Miller" <davem@redhat.com> wrote:

>On Fri, 25 Jun 2004 12:39:53 +0200
>"Angelo Dell'Aera" <buffer@antifork.org> wrote:
>
>> I just want to point out to you a really interesting article published
>> by  two  members   of  my  research  group.  The   paper  is  entitled
>> "Performance  Evaluation and  Comparison  of Westwood+,  New Reno  and
>> Vegas TCP  Congestion Control" and  it aims at evaluating  these three
>> algorithms in really different scenarios.

>Would be interesting  to compare with BITCP which  we have enabled by
>default now in current 2.6.x kernels.

Dave,
I had suggested  to do this to the members of  my research group since
I'm goin' away from there. But I wanted to say just few things.

First of all I  know not too much about BITCP but  I think it's unsafe
to enable it by default... just  like it's unsafe to enable by default
any kind of new congestion control algorithm.

I worked  in this research  field in  the last year  and a half  and I
realized that the perfect algorithm doesn't exist.  For example in the
paper  about BITCP  I  read  it's `RTT  fair'  since its  steady-state
throughput  is  inversely  proportional   to  RTT  (the  same  as  TCP
NewReno). In  this situation, TCP Westwood+ behaviour  is better since
its steady-state  throughput is  inversely proportional to  the square
root of RTT.

But TCP  Westwood+ has no so smart  mechanisms as BITCP in  a long fat
pipe context.  So different  scenarios lead to  different performances
for these algorithms.

So IMHO I think the default should always be TCP NewReno and we should
give the possibility to anyone to  choose what he/she wants to use for
his/her purposes.

Another thing.  I think it's  necessary to provide some  mechanism for
enabling  just one  of these  algorithms at  a time.  Some days  ago I
started 2.6.7-mm1 and I found  myself with BITCP and Westwood+ enabled
at  the same  time. Maybe  in  the future  a merge  between these  two
algorithms could even be a good thing to realize but now I had no time
to look at the sources for realizing if `crazy things' could happen...
what do you think about it?

And just another thing. I think TCP Vegas is a quite good example of a
first try  of realizing a  smart congestion control algorithm  but too
many studies  has shown  it's unable to  work properly in  presence of
reverse traffic (which happens almost  always in the real world). Yes,
it is fair..  but I think it's not enough. IMHO  no one wants fairness
throwing away bandwidth..  Conclusion : IMHO TCP Vegas patch has to be
reversed...


Regards. 


- --

Angelo Dell'Aera 'buffer' 
Antifork Research, Inc.	  	http://buffer.antifork.org

PGP information in e-mail header


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA4bYqpONIzxnBXKIRAsdrAJ9zdutB1m5HbDbvXBk/ouqTrJ5AHgCePetU
pdcoVDk/Gcu0VAsvsA21aq4=
=lt0y
-----END PGP SIGNATURE-----
