From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Thu, 3 Dec 2015 09:23:34 +0100
Message-ID: <4C2AFE05-10C2-412C-B065-B57CFCBEDD9A@profihost.ag>
References: <564B3D35.50004@profihost.ag> <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag> <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag> <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag> <564D9A17.6080305@redhat.com> <564D9B21.302@profihost.ag> <564D9CE6.2090104@profihost.ag> <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com> <564DB5F5.9060208@profihost.ag> <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com> <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com> <564E2852.8000200@profihost.ag> <56530A42.6030609@profihost.ag> <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com> <565EBDC1.1090808@profihost.ag> <8737vlt6xb.fsf@stressinduktion.org>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737vlt6xb.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Am 02.12.2015 um 12:40 schrieb Hannes Frederic Sowa <hannes@stressinduktion.org>:
> 
> Hello Stefan,
> 
> Stefan Priebe - Profihost AG <s.priebe@profihost.ag> writes:
> 
> 
>> here are the results.
>> 
>> It works with 4.1.
>> It works with 4.2.
>> It does not work with 4.1.13.
>> 
>> git bisect tells me it stopped working after those two commits were applied:
>> 
>> commit d48623677191e0f035d7afd344f92cf880b01f8e
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Tue Sep 22 11:38:56 2015 +0800
>> 
>>    netlink: Replace rhash_portid with bound
>> 
>> commit 4e27762417669cb459971635be550eb7b5598286
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Fri Sep 18 19:16:50 2015 +0800
>> 
>>    netlink: Fix autobind race condition that leads to zero port ID
> 
> Cool, thanks a lot. Does this patch make a difference?
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 59651af..278e94c 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1137,7 +1137,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
> 
>    /* We need to ensure that the socket is hashed and visible. */
>    smp_wmb();
> -    nlk_sk(sk)->bound = portid;
> +    nlk_sk(sk)->bound = true;
> 
> err:
>    release_sock(sk);

Will try that soon but already started another test. I reverted all netlink patches from 4.1.13 back to 4.1 and applied all netlink patches from 4.1 up to 4.3.

Greets,
Stefan