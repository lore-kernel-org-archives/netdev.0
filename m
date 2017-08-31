From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net-next 6/7] samples/bpf: xdp_redirect load XDP dummy
 prog on TX device
Date: Thu, 31 Aug 2017 13:08:22 +0300
Message-ID: <be534824-72d9-5f58-70bd-45cca0877330@mellanox.com>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
 <150401748630.16384.478521489037692464.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0041.outbound.protection.outlook.com ([104.47.0.41]:25034
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750757AbdHaKI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 06:08:29 -0400
In-Reply-To: <150401748630.16384.478521489037692464.stgit@firesoul>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

On 29/08/2017 5:38 PM, Jesper Dangaard Brouer wrote:
>   
> +/* Redirect require an XDP bpf_prog loaded on the TX device */
> +SEC("xdp_redirect_dummy")
> +int xdp_redirect_dummy(struct xdp_md *ctx)
> +{
> +	return XDP_PASS;
> +}
> +

I get a compilation error related to this:

$ make samples/bpf/

...
LLVM ERROR: 'xdp_redirect_dummy' label emitted multiple times to 
assembly file
make[1]: *** [samples/bpf/xdp_redirect_kern.o] Error 1
make: *** [samples/bpf/] Error 2


It can be fixed by the following patch.
I can submit it in a separate mail if you want to.


diff --git a/samples/bpf/xdp_redirect_kern.c 
b/samples/bpf/xdp_redirect_kern.c
index 1c90288d0203..8abb151e385f 100644
--- a/samples/bpf/xdp_redirect_kern.c
+++ b/samples/bpf/xdp_redirect_kern.c
@@ -82,7 +82,7 @@ int xdp_redirect_prog(struct xdp_md *ctx)

  /* Redirect require an XDP bpf_prog loaded on the TX device */
  SEC("xdp_redirect_dummy")
-int xdp_redirect_dummy(struct xdp_md *ctx)
+int xdp_redirect_dummy_prog(struct xdp_md *ctx)
  {
         return XDP_PASS;
  }
diff --git a/samples/bpf/xdp_redirect_map_kern.c 
b/samples/bpf/xdp_redirect_map_kern.c
index 79795d41ad0d..740a529ba84f 100644
--- a/samples/bpf/xdp_redirect_map_kern.c
+++ b/samples/bpf/xdp_redirect_map_kern.c
@@ -84,7 +84,7 @@ int xdp_redirect_map_prog(struct xdp_md *ctx)

  /* Redirect require an XDP bpf_prog loaded on the TX device */
  SEC("xdp_redirect_dummy")
-int xdp_redirect_dummy(struct xdp_md *ctx)
+int xdp_redirect_dummy_prog(struct xdp_md *ctx)
  {
         return XDP_PASS;
  }


Regards,
Tariq
