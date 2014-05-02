From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Sat, 3 May 2014 00:18:28 +0200
Message-ID: <594896976.20140503001828@eikelenboom.it>
References: <395225650.20140430124506@eikelenboom.it> <536250F9.7060405@citrix.com> <1967602892.20140501160513@eikelenboom.it> <53626563.8010404@citrix.com> <1046603646.20140501174053@eikelenboom.it> <1399044933.29914.242.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:54021 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbaEBWSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 18:18:34 -0400
In-Reply-To: <1399044933.29914.242.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Friday, May 2, 2014, 5:35:33 PM, you wrote:

> Delivery-date: Fri, 02 May 2014 17:35:34 +0200
> Received: from Debian-exim by smtp.eikelenboom.it with spam-scanned (Exim 4.80)
>         id 1WgFUq-0000eq-KA
>         for linux@eikelenboom.it; Fri, 02 May 2014 17:35:34 +0200
> X-Spam-Checker-Version: SpamAssassin 3.3.2 (2011-06-06) on
>         vserver.eikelenboom.it
> X-Spam-Level: 
> X-Spam-Status: No, score=-1.0 required=5.0 tests=BAYES_00=-0.2,DKIM_SIGNED=0.1,
>         DKIM_VALID=-0.1,DKIM_VALID_AU=-0.1,FREEMAIL_FROM=0.001,RCVD_IN_DNSWL_LOW=-0.7,
>         SPF_PASS=-0.001 autolearn=ham version=3.3.2
> X-Spam-BayesTokenSummary: Tokens: new, 21; hammy, 148; neutral, 63; spammy, 3.
> X-Spam-BayesSpammyTokens: 0.966-4308--1028h-6995s--0d--HTo:U*linux,
>         0.966-4310--1036h-7008s--0d--HTo:D*eikelenboom.it,
>         0.966-4312--1037h-7012s--0d--HTo:D*it
> X-Spam-BayesHammyTokens: 0.000-641--14739h-0s--0d--H*Ad:D*xen.org,
>         0.000-639--14706h-0s--0d--H*Ad:D*lists.xen.org,
>         0.000-362--8322h-0s--0d--UD:git, 0.000-303--6966h-0s--0d--mapping,
>         0.000-219--5029h-0s--0d--stack, 0.000-140--3222h-0s--0d--sander,
>         0.000-138--3167h-0s--0d--Sander, 0.000-131--3009h-0s--0d--UD:kernel.org,
>         0.000-131--3005h-0s--0d--eikelenboom, 0.000-131--3002h-0s--0d--Eikelenboom
> X-Spam-Language: en
> Received: from mail-ig0-f171.google.com ([209.85.213.171]:58796)
>         by smtp.eikelenboom.it with esmtps (TLS1.0:RSA_ARCFOUR_SHA1:128)
>         (Exim 4.80)
>         (envelope-from <eric.dumazet@gmail.com>)
>         id 1WgFUq-0000ed-EB
>         for linux@eikelenboom.it; Fri, 02 May 2014 17:35:32 +0200
> Received: by mail-ig0-f171.google.com with SMTP id c1so2017155igq.10
>         for <linux@eikelenboom.it>; Fri, 02 May 2014 08:35:53 -0700 (PDT)
> DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
>         d=gmail.com; s=20120113;
>         h=message-id:subject:from:to:cc:date:in-reply-to:references
>          :content-type:content-transfer-encoding:mime-version;
>         bh=HjfRSMRPZB/ma6/RU17OdK4juguAgkF/PdzxJpKZyN0=;
>         b=Qw3KcZtjJQZ4zihNDsygRcQYcMnIdxdwHIKkSjShbP4vQt9got8xSujeNIsz76pcu/
>          eABUkDykarQ2cdBeIM2bTvcWftWMV/SyDppafAyk7S3w4fm43EaI9sNTWvUEmA4rHvKC
>          9LJdOV7zEbGfYoy/mqlzxsm3JETO+Bzm9rIXmsUMZXQL0vGoY/dUkvuEQTHActHbJln+
>          h10jjkCMTxo7k8et5ocFSVEK5Nz5F0v8RJvXwKHX9lf5ESIhBX9RUzMfyi46HxLlUNek
>          Vm1xyxIsL2VI0g8lHlVz4FqPbdjZTzrs4TUsB/5SOcgB+opy54Fq6Lwl5DHB5isgDkxL
>          YSUA==
> X-Received: by 10.42.25.11 with SMTP id y11mr17216392icb.10.1399044953393;
>         Fri, 02 May 2014 08:35:53 -0700 (PDT)
> Received: from [172.26.54.213] ([172.26.54.213])
>         by mx.google.com with ESMTPSA id g1sm7621447igt.14.2014.05.02.08.35.47
>         for <multiple recipients>
>         (version=SSLv3 cipher=RC4-SHA bits=128/128);
>         Fri, 02 May 2014 08:35:52 -0700 (PDT)
> Message-ID: <1399044933.29914.242.camel@edumazet-glaptop2.roam.corp.google.com>
> Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
>  guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
>  instead of copy" series.
> From: Eric Dumazet <eric.dumazet@gmail.com>
> To: Sander Eikelenboom <linux@eikelenboom.it>
> Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, Ian Campbell
>  <Ian.Campbell@citrix.com>,  "David S. Miller" <davem@davemloft.net>,
>  netdev@vger.kernel.org, xen-devel@lists.xen.org, Neal Cardwell
>  <ncardwell@google.com>
> Date: Fri, 02 May 2014 08:35:33 -0700
> In-Reply-To: <1046603646.20140501174053@eikelenboom.it>
> References: <395225650.20140430124506@eikelenboom.it>
>          <536250F9.7060405@citrix.com> <1967602892.20140501160513@eikelenboom.it>
>          <53626563.8010404@citrix.com> <1046603646.20140501174053@eikelenboom.it>
> Content-Type: text/plain; charset="UTF-8"
> X-Mailer: Evolution 3.2.3-0ubuntu6 
> Content-Transfer-Encoding: 7bit
> Mime-Version: 1.0

> On Thu, 2014-05-01 at 17:40 +0200, Sander Eikelenboom wrote:

>> Yesterday i tried to get packetdrill (https://code.google.com/p/packetdrill/) to 
>> work to see if i could reproduce with one of it's tests, but didn't get the 
>> client server stuff working. It seems it has helped with finding and fixing 
>> previous kernel networking bugs.

> If you use recent net-next kernel, you need a packetdrill patch, Neal
> might submit it shortly on packetdrill repo.

> packetdrill currently does not consume the packets sent on the tun
> device, so this triggers the new [1] TCP stack behavior detecting packet
> did not yet leaved the host.

> [1] :
> ( http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1f3279ae0c13cd742731726b0ed195d5f09b14e4 )

I applied the patch from the thread above, but i still can't get it to work.

Hmm i'm trying to do it client-server over the bridge, since that is what i 
would like to test and from what i read from the sparse documentation that 
should be possible:

So on the xen guest (that is on a bridge) i run:
./packetdrill --wire_server

And on the host (dom0):
./packetdrill  -v --wire_client --wire_server_ip=192.168.1.9 --ip_version=ipv4  test-file

Only reaction i get is on the guest:
inbound injected packet:  0.100252 S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>

But nothing more seems to happen after that, the test doesn't complete or return, but i also don't 
see any more traffic on the port (8081) used by packetdrill on the guest.

--
Sander
