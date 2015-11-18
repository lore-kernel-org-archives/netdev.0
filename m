From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-scm: Macro for special pattern?
Date: Wed, 18 Nov 2015 04:43:50 -0800
Message-ID: <1447850630.22599.140.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5307CAA2.8060406@users.sourceforge.net>
	 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	 <530A086E.8010901@users.sourceforge.net>
	 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	 <530A72AA.3000601@users.sourceforge.net>
	 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	 <530B5FB6.6010207@users.sourceforge.net>
	 <alpine.DEB.2.10.1402241710370.2074@hadrien>
	 <530C5E18.1020800@users.sourceforge.net>
	 <alpine.DEB.2.10.1402251014170.2080@hadrien>
	 <530CD2C4.4050903@users.sourceforge.net>
	 <alpine.DEB.2.10.1402251840450.7035@hadrien>
	 <530CF8FF.8080600@users.sourceforge.net>
	 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	 <530DD06F.4090703@users.sourceforge.net>
	 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	 <5317A59D.4@users.sourceforge.net> <564B5937.1070707@users.sourceforge.net>
	 <564B602F.2020302@iogearbox.net> <564B6C6F.3070809@users.sourceforge.net>
	 <564B73D7.7040501@iogearbox.net> <564C2CB5.5010507@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564C2CB5.5010507@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-11-18 at 08:45 +0100, SF Markus Elfring wrote:
> > You mean this likely() annotation of yours?
> 
> How do you think about to express the software design pattern
> which is applied at the mentioned source code place by a dedicated
> preprocessor macro?

likely()/unlikely() are not always applicable.

In the Ipv6 case I mentioned to you, it all depends if an application
for some reason absolutely wants the sockets to store the extra skb

There are seldom used socket options. _if_/_when_ they are used, a
likely()/unlikely() would give the wrong signal.

likely() should only be used in contexts we know better than branch
predictor/compiler.
