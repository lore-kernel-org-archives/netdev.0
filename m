From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 0/3] crypto: algif - change algif_skcipher to be asynchronous
Date: Mon, 02 Feb 2015 17:40:07 +0100
Message-ID: <17805101.rkttaZiZYV@tauon>
References: <20150129231338.25156.65450.stgit@tstruk-mobl1> <1653087.XMGL7JlhQx@tachyon.chronox.de> <54CF91A6.2020100@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, qat-linux@intel.com,
	linux-kernel@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <54CF91A6.2020100@intel.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 2. Februar 2015, 07:03:02 schrieb Tadeusz Struk:

Hi Tadeusz,

>On 02/01/2015 10:31 AM, Stephan Mueller wrote:
>> Hi Tadeusz,
>> 
>>> > The way the algif_skcipher works currently is that on
>>> > sendmsg/sendpage it builds an sgl for the input data and then on
>>> > read/recvmsg it sends the job for encryption putting the user to
>>> > sleep till the data is processed. This way it can only handle one
>>> > job at a given time.
>>> > To be able to fuly utilize the potential of existing crypto
>>> > hardware
>>> > accelerators it is required to submit multiple jobs in
>>> > asynchronously.
>>> > First patch enables asynchronous read and write on socket.
>>> > Second patch enables af_alg sgl to be linked.
>>> > Third patch implement asynch read for skcipher.
>> 
>> Do you have a code fragment on how to test that patch? I would like
>> to see whether I can test that with my libkcapi.
>
>Hi Stephan,
>This is what I'm using.

Thanks for the listing.

Are you aware of the speed tester that I added to libkcapi? See [1] 
subdir speed-test/

If you want to play with it, all you need to do is to add your 
init/encryption/fini code into cryptoperf-skcipher.c.

The key is that cp_ablkcipher_enc_test/cp_ablkcipher_dec_test performs 
only the encryption/decryption operation (setkey, etc is done in the 
init call). The speed measuring is done only over that function.

[1] http://www.chronox.de/libkcapi.html

Ciao
Stephan
