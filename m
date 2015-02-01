From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 0/3] crypto: algif - change algif_skcipher to be asynchronous
Date: Sun, 01 Feb 2015 19:31:06 +0100
Message-ID: <1653087.XMGL7JlhQx@tachyon.chronox.de>
References: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, qat-linux@intel.com,
	linux-kernel@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 29. Januar 2015, 15:13:39 schrieb Tadeusz Struk:

Hi Tadeusz,

> The way the algif_skcipher works currently is that on sendmsg/sendpage it
> builds an sgl for the input data and then on read/recvmsg it sends the job
> for encryption putting the user to sleep till the data is processed.
> This way it can only handle one job at a given time.
> To be able to fuly utilize the potential of existing crypto hardware
> accelerators it is required to submit multiple jobs in asynchronously.
> First patch enables asynchronous read and write on socket.
> Second patch enables af_alg sgl to be linked.
> Third patch implement asynch read for skcipher.

Do you have a code fragment on how to test that patch? I would like to see 
whether I can test that with my libkcapi.
> 
> Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
> ---
> Tadeusz Struk (3):
>       net: socket: enable async read and write
>       crypto: af_alg - Allow to link sgl
>       crypto: algif - change algif_skcipher to be asynchronous
> 
> 
>  crypto/af_alg.c         |   16 ++
>  crypto/algif_skcipher.c |  315
> ++++++++++++++++++++++++++++++++++++++++++++++- include/crypto/if_alg.h |  
>  4 -
>  include/net/sock.h      |    2
>  net/socket.c            |   48 ++++++-
>  5 files changed, 364 insertions(+), 21 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-crypto" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ciao
Stephan
