From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 18 Jul 2008 11:14:51 +0200
Message-ID: <200807181114.53059.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807171715.16265.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807171819160.13775@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?iso-8859-15?q?D=E2niel?= Fraga" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807171819160.13775@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moi Ilpo,

On Thursday, 17. July 2008 17:53:01 Ilpo J=E4rvinen wrote:
> > > One option would be to disable reentry to FRTO when some progress=
 was
> > > made... Please try with the patch below...
>
> Ah, I just forgot that the situation might persist... Try with this
> one instead...

Good news everyone: Two connections made it to the finish line.

The bad part: One transfer took four minutes, the other sixteen minutes=
=2E
A colleague commented it's still much faster than carrying the message
by plane ;-) A session without FRTO takes around 84 seconds.

I've added debug printks() to every return path in tcp_use_frto(),
so you can see what's going on. They look like this:

Jul 18 10:20:40 intratest131 kernel: [  957.318006] tcp_use_frto: ENTER=
: frto_counter: 0, icsk->icsk_ca_state: 0
Jul 18 10:20:40 intratest131 kernel: [  957.318011] tcp_use_frto: DEFAU=
LT RETURN 1;
Jul 18 10:21:08 intratest131 kernel: [  984.446006] tcp_use_frto: ENTER=
: frto_counter: 3, icsk->icsk_ca_state: 0
Jul 18 10:21:08 intratest131 kernel: [  984.446011] tcp_use_frto: RETUR=
N in "tp->frto_counter > 1 || icsk->icsk_ca_state =3D=3D TCP_CA_Loss"
Jul 18 10:21:14 intratest131 kernel: [  991.058006] tcp_use_frto: ENTER=
: frto_counter: 0, icsk->icsk_ca_state: 0
Jul 18 10:21:14 intratest131 kernel: [  991.058011] tcp_use_frto: DEFAU=
LT RETURN 1;

Here are two new dumps and the corresponding debug traces:
http://www.intra2net.com/de/download/tcpdump/tcp_frto_second_patch.tar.=
bz2

Enjoy,
Thomas
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
