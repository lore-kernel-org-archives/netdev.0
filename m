From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Acrypto asynchronous crypto layer 2.6.19 release.
Date: Tue, 19 Dec 2006 13:59:16 +0300
Message-ID: <20061219105916.GA22473@2ka.mipt.ru>
References: <20061216191521.GA26549@2ka.mipt.ru> <4586458E.6000503@dungeon.inka.de> <20061218095740.GA5219@2ka.mipt.ru> <458690EA.2000405@ciphirelabs.com> <20061218131356.GA11186@2ka.mipt.ru> <4587C415.9020706@ciphirelabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36082 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932783AbWLSK7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 05:59:24 -0500
To: Andreas Jellinghaus <aj@ciphirelabs.com>
Content-Disposition: inline
In-Reply-To: <4587C415.9020706@ciphirelabs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 19, 2006 at 11:51:01AM +0100, Andreas Jellinghaus (aj@ciphirelabs.com) wrote:
> Evgeniy Polyakov wrote:
> >You can change it in async_provider in compilation time or I can create
> >module version. There is an item in related todo list to use crypto
> >contexts, they were created exactly for such kind of things (actually
> >for hardware devices which do not support realtime key changes).
> 
> ok, what do I need to change to get aes-cbc-essiv:sha256 support
> so I can use acrypto with my current dm-crypt'ed partitions?

For AES CBC only set of supported operations should be extended.
Something like patch below:

diff --git a/acrypto/async_provider.c b/acrypto/async_provider.c
index ac11708..186cc5c 100644
--- a/acrypto/async_provider.c
+++ b/acrypto/async_provider.c
@@ -48,6 +48,12 @@ static struct acrypto_capability prov_caps[] = {
 		
 		{ACRYPTO_OP_ENCRYPT, ACRYPTO_TYPE_AES_128, ACRYPTO_MODE_CBC, 1000},
 		{ACRYPTO_OP_DECRYPT, ACRYPTO_TYPE_AES_128, ACRYPTO_MODE_CBC, 1000},
+		
+		{ACRYPTO_OP_ENCRYPT, ACRYPTO_TYPE_AES_192, ACRYPTO_MODE_CBC, 1000},
+		{ACRYPTO_OP_DECRYPT, ACRYPTO_TYPE_AES_192, ACRYPTO_MODE_CBC, 1000},
+		
+		{ACRYPTO_OP_ENCRYPT, ACRYPTO_TYPE_AES_256, ACRYPTO_MODE_CBC, 1000},
+		{ACRYPTO_OP_DECRYPT, ACRYPTO_TYPE_AES_256, ACRYPTO_MODE_CBC, 1000},
 };
 static int prov_cap_number = sizeof(prov_caps)/sizeof(prov_caps[0]);
 

-- 
	Evgeniy Polyakov
