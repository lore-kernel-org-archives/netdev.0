From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: nfc: BUG and panic in accept() on 3.5-rc2
Date: Mon, 11 Jun 2012 16:41:33 +0200
Message-ID: <1339425693.6001.2268.camel@edumazet-glaptop>
References: <1339423241.4999.53.camel@lappy>
	 <20120611144134.GX22557@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <levinsasha928@gmail.com>,
	David Miller <davem@davemloft.net>,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	Dave Jones <davej@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120611144134.GX22557@sortiz-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-11 at 16:41 +0200, Samuel Ortiz wrote:
> Hi Sasha,
> 
> On Mon, Jun 11, 2012 at 04:00:41PM +0200, Sasha Levin wrote:
> > Hi all,
> > 
> > I've stumbled on the following while fuzzing with trinity inside a KVM tools guest, running on 3.5-rc2:
> > 
> Thanks for the report, it could be worth adding this one to
> bugzilla.kernel.org.
> 
> What's trinity ?
> Also, if this one is reproducible, would you mind sharing some details about
> how we could reproduce it ?

Well, bugfix should be trivial enough ;)

diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index ec1134c..208416e 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -54,11 +54,12 @@ static int rawsock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	pr_debug("sock=%p\n", sock);
-
-	sock_orphan(sk);
-	sock_put(sk);
+	pr_debug("sock=%p sk=%p\n", sock, sk);
 
+	if (sk) {
+		sock_orphan(sk);
+		sock_put(sk);
+	}
 	return 0;
 }
 
