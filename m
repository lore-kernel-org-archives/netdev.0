From: Philipp Hahn <pmhahn@pmhahn.de>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 02 Dec 2015 18:51:52 +0100
Message-ID: <565F2FB8.9010006@pmhahn.de>
References: <564B3D35.50004@profihost.ag> <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag> <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag> <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag> <564D9A17.6080305@redhat.com> <564D9B21.302@profihost.ag> <564D9CE6.2090104@profihost.ag> <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com> <564DB5F5.9060208@profihost.ag> <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com> <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com> <564E2852.8000200@profihost.ag> <56530A42.6030609@profihost.ag> <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com> <565EBDC1.1090808@profihost.ag> <8737vlt6xb.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737vlt6xb.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Am 02.12.2015 um 12:40 schrieb Hannes Frederic Sowa:
> Cool, thanks a lot. Does this patch make a difference?
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 59651af..278e94c 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1137,7 +1137,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
>  
>  	/* We need to ensure that the socket is hashed and visible. */
>  	smp_wmb();
> -	nlk_sk(sk)->bound = portid;
> +	nlk_sk(sk)->bound = true;
>  
>  err:
>  	release_sock(sk);

Will test that tomorrow.

What confuss me is that it works with 4.3. I compared
net/netlink/af_netlink.[ch] for differences between v4.1.10 and v4.3 and
didn't find anything which would explain only 4,1 getting stuck.

Philipp
