From: Ludo Stellingwerff <ludo@protactive.nl>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Sun, 20 Mar 2005 17:32:13 +0100
Message-ID: <423DA58D.4050406@protactive.nl>
References: <20050214221607.GC18465@gondor.apana.org.au>	<20050306213214.7d8a143d.davem@davemloft.net>	<20050307103536.GB7137@gondor.apana.org.au>	<20050308102741.GA23468@gondor.apana.org.au>	<20050314102614.GA9610@gondor.apana.org.au>	<20050314105313.GA21001@gondor.apana.org.au>	<20050314111002.GA29156@gondor.apana.org.au>	<20050315091904.GA6256@gondor.apana.org.au>	<20050315095837.GA7130@gondor.apana.org.au>	<20050318090310.GA28443@gondor.apana.org.au>	<20050318091129.GA28658@gondor.apana.org.au> <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <423D9ADA.6050407@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

As an daily user of Patricks patches, I like to agree with Patricks
analysis about the loosing of flexibility with the choice not to use
virtual devices. In a real-life situation I had to revert to using
plain, unsave GRE-tunnels because of the complexity of using 2.6-ipsec
for the same purpose. I'm routing one of multiple defaultroutes over
this tunnel:) It felt like a relieve having a device to work with.

Just my 2 cents,
Greetings,
Ludo.

Patrick McHardy wrote:

| David S. Miller wrote:
|
|> On Fri, 18 Mar 2005 20:11:29 +1100 Herbert Xu
|> <herbert@gondor.apana.org.au> wrote:
|>
|>> BTW Patrick, how is the IPsec netfilter stuff going?
|>
|>
|> That boy is seriously backlogged, so I'm not sure how much time
|> he's gotten to work on that yet.
|
|
| Indeed, but in case of the netfilter patches that's not the
| problem. They are basically working fine, but I have doubts about
| submitting them. First, and most importantly, the input patch is
| incredible ugly. To recap, we want to pass the encapsulated packets
| to the netfilter hooks, then again the decapsulated packets after
| all decapsulation has been done. The current input patch makes
| packets that have been handled by IPsec skip the netfilter hooks
| until we know no further IPsec processing will be done (route is
| non-local or protocol handler is not marked as xfrm_prot). The
| packet is then marked as completely decapsulated and passed through
| the stack again and the plain packets go through netfilter again.
| There are a couple of problems with this approach:
|
| - decapsulated tunnel-mode packets go through the stack twice -
| netfilter only sees them once, everything else multiple times
| (statistics, packet sockets, ...) - racy, xfrm protocol could be
| registered after we determined decapsulation is done. - inefficient
|
|
| The second reason is that I'm not sure at all wether this is the
| way to go. With KLIPS-like IPsec-devices you can sniff the plain
| packets before they are handled by IPsec and you can perform
| traffic shaping on them. These two points are completely unhandled,
| and people seem to want them.
|
| So what's holding back these patches is getting some consensus on
| what exactly we want to do and finding a better method for
| determining when decapsulation is done. One possibility would be
| stealing packets in xfrm_policy_check(), but I haven't thought much
| about this yet.
|
| Regards Patrick
|
|

- --
Ludo Stellingwerff

V&S B.V. The Netherlands
ProTactive firewall solution.
Tel: +31 172 416116
Fax: +31 172 416124

site: www.protactive.nl
demo: http://www.protactive.nl:81/netview.html
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCPaWMOF3sCpZ+AJgRAiofAJ9VlmQ3GF+D3q5FLfsyj3vcRJUbogCgzy86
pS4CRtw1sGe3K3vUVgIqi8E=
=5IAn
-----END PGP SIGNATURE-----
