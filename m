From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 19 Aug 2008 13:38:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808181042290.23854@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
 <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi> <20080813145310.0c1e534c@tux>
 <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi> <20080815013407.4a594288@tux>
 <Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi> <20080815183511.1c81be23@tux>
 <Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi> <20080815231538.7999c017@tux>
 <Pine.LNX.4.64.0808161002500.7264@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0808162210390.7443@wrl-59.cs.helsinki.fi> <20080816213615.689ddf8f@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-650319758-1219045458=:23854"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080816213615.689ddf8f@tux>
Content-ID: <Pine.LNX.4.64.0808191331010.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-650319758-1219045458=:23854
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808191028171.4551@wrl-59.cs.helsinki.fi>

On Sat, 16 Aug 2008, Dâniel Fraga wrote:

> On Sat, 16 Aug 2008 22:18:50 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > I'll look through 2.6.24..25 history once I have some time to see if 
> > there are some clues about the cause. I'm also having a problem in 
> > figurin out why would the frto patch you tested solve this issue (unless 
> > there are two issues in the picture).
> 
> 	Ok, surely some patch between .24 and .25 caused this. Or it's
> some bug that only "appeared" in .25 :)
> 
> 	In fact, the frto patch helped, but not prevented the problem.
> I mean, it seems that with the frto patch, the problem doesn't happen
> frequently. And if I disable frto, the problem doesn't occur either.
> 
> 	But, maybe, we could be talking about another bug, completely
> unrelated to frto... I don't know. i'm just guessing ;). Anyway, we
> talk about stalled connections ;)
>
> 	What I know is:
> 
> 1) what you wrote is right: 2.6.24 is fine, 2.6.25 and 2.6.26 not
> 
> 2) nmap -sS <server> seems to reset the connection (it's my workaround
> until now ;). Maybe the ping probe help in some way? I don't know.

Perhaps, though it's not at all clear how it could do that...

> 	I want to help you as much as I can. So, ask anything you need.

I went through TCP related and inet_connection_sock related things, 
nothing obvious I could notice in there...

Do you have net namespaces enabled CONFIG_NET_NS in .config?

Any netfilter (iptables) rules on server which could cause those packets 
to not reach TCP layer?

MIBs might give some clue why those segments didn't get accepted. Most 
interesting ones are PAWSEstab, TCPAbortOnSyn and InErrs. One can use 
/bin/cut to read those from the one-line files if one wants to (however,
I attached a script which transposes them to get them somewhat 
human-readable). Also having the /proc/net/tcp output from the server 
while stalling would be (have been) useful to reveal state info (but I 
should have remembered to ask you to run it on both of them :-)). 

Also, I wonder what that [|tcp] hides, e.g., "<nop,nop,timestamp 
15980976 70381399,nop,nop,[|tcp]>" in tcpdump (and that was for an ACK 
which doesn't make too much sense to me there). It occurs because 
snaplen which was given for tcpdump is small enough to make TCP header 
partial.


-- 
 i.
---696208474-650319758-1219045458=:23854
Content-Type: APPLICATION/X-SH; name=readmibs.sh
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0808191251200.4551@wrl-59.cs.helsinki.fi>
Content-Description: 
Content-Disposition: attachment; filename=readmibs.sh

IyEvYmluL3NoCgplY2hvICJNSUJzIChuZXRzdGF0KSBvbiAkSE9TVE5BTUU6
ICIKYXdrICd7Zm9yKGk9MTtpPD1ORjtpKyspIGJha1tpXSA9ICRpOyBnZXRs
aW5lOyBmb3IoaSA9IDE7IGkgPD0gTkY7IGkrKykgcHJpbnRmKCIlMzJzICVz
XG4iLCAgYmFrW2ldLCRpKX0nIDwgL3Byb2MvbmV0L25ldHN0YXQKZWNobyAi
IgoKZWNobyAiTUlCcyAoc25tcCkgb24gJEhPU1ROQU1FOiAiCmdyZXAgIklw
OiAiIC9wcm9jL25ldC9zbm1wIHwgYXdrICd7Zm9yKGk9MTtpPD1ORjtpKysp
IGJha1tpXSA9ICRpOyBnZXRsaW5lOyBmb3IoaSA9IDE7IGkgPD0gTkY7IGkr
KykgcHJpbnRmKCIlMzJzICVzXG4iLCAgYmFrW2ldLCRpKX0nCmdyZXAgIklj
bXA6ICIgL3Byb2MvbmV0L3NubXAgfCBhd2sgJ3tmb3IoaT0xO2k8PU5GO2kr
KykgYmFrW2ldID0gJGk7IGdldGxpbmU7IGZvcihpID0gMTsgaSA8PSBORjsg
aSsrKSBwcmludGYoIiUzMnMgJXNcbiIsICBiYWtbaV0sJGkpfScKZ3JlcCAi
VGNwOiAiIC9wcm9jL25ldC9zbm1wIHwgYXdrICd7Zm9yKGk9MTtpPD1ORjtp
KyspIGJha1tpXSA9ICRpOyBnZXRsaW5lOyBmb3IoaSA9IDE7IGkgPD0gTkY7
IGkrKykgcHJpbnRmKCIlMzJzICVzXG4iLCAgYmFrW2ldLCRpKX0nCiNncmVw
ICJVZHA6ICIgL3Byb2MvbmV0L3NubXAgfCBhd2sgJ3tmb3IoaT0xO2k8PU5G
O2krKykgYmFrW2ldID0gJGk7IGdldGxpbmU7IGZvcihpID0gMTsgaSA8PSBO
RjsgaSsrKSBwcmludGYoIiUzMnMgJXNcbiIsICBiYWtbaV0sJGkpfScKZWNo
byAiIgoKIyBjYXQgL3Byb2MvbmV0L3NubXA2Cg==

---696208474-650319758-1219045458=:23854--
