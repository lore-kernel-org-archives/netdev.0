From: "David S. Miller" <davem@redhat.com>
Subject: Re: Check connect address in NETLINK
Date: Wed, 30 Jun 2004 15:36:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630153606.3493581b.davem@redhat.com>
References: <20040628231439.GA3021@gondor.apana.org.au>
	<20040629082252.GA26866@ms2.inr.ac.ru>
	<20040629084552.GA6202@gondor.apana.org.au>
	<20040629111433.GA28463@ms2.inr.ac.ru>
	<20040629111833.GA22880@gondor.apana.org.au>
	<20040630112751.GA31160@gondor.apana.org.au>
	<20040630120045.GA7973@ms2.inr.ac.ru>
	<20040630120828.GA31498@gondor.apana.org.au>
	<20040630121420.GA8183@ms2.inr.ac.ru>
	<20040630124050.GA1619@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040630124050.GA1619@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Why don't you combine the two "ERR_PTR(-ECONNREFUSED)" tests
into one test like:

	if ((nlk->pid == 0 && !nlk->data_ready) ||
	    (sock->sk_state == NELTINK_CONNECTED &&
	     nlk->dst_pid != nlk_sk(ssk)->pid)) {
		sock_put(sock);
		return ERR_PTR(-ECONNREFUSED);
	}

so we don't have two copies of the "sock_put(); return ERR_PTR()"
thing emitted by the compiler?
