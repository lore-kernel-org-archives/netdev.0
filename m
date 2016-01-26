From: Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 16/26] libceph: Use skcipher
Date: Tue, 26 Jan 2016 12:29:57 +0100
Message-ID: <CAOi1vP9kB5a-JeZ1PriwyQO0XH4Qh3UKidp==NPvVw-AsL=uqw@mail.gmail.com>
References: <20160124131021.GA31153@gondor.apana.org.au>
	<E1aNKYy-0008E6-GI@gondolin.me.apana.org.au>
	<CAOi1vP9jmMYHR21UeAO175susZ5V74vcXyoxwayBVSTFHxjhBQ@mail.gmail.com>
	<20160126105455.GA19674@gondor.apana.org.au>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Crypto Mailing List <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ceph Development <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Lars Ellenberg <drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>,
	open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <open-iscsi+bncBCWIHX4L7AKRBNNRTW2QKGQEFE46HRY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <20160126105455.GA19674-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 11:54 AM, Herbert Xu
<herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> wrote:
> On Mon, Jan 25, 2016 at 05:18:47PM +0100, Ilya Dryomov wrote:
>>
>> Could you get rid of ivsize instead of assigning to it - see the
>> attached diff?
>
> How about an incremental patch like this? Thanks!
>
> ---8<---
> From: Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Subject: libceph: Remove unnecessary ivsize variables
>
> This patch removes the unnecessary ivsize variabls as they always
> have the value of AES_BLOCK_SIZE.
>
> Signed-off-by: Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
> index fb9cb2b..db2847a 100644
> --- a/net/ceph/crypto.c
> +++ b/net/ceph/crypto.c
> @@ -166,8 +166,7 @@ static int ceph_aes_encrypt(const void *key, int key_len,
>         struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
>         SKCIPHER_REQUEST_ON_STACK(req, tfm);
>         int ret;
> -       int ivsize = AES_BLOCK_SIZE;
> -       char iv[ivsize];
> +       char iv[AES_BLOCK_SIZE];
>         size_t zero_padding = (0x10 - (src_len & 0x0f));
>         char pad[16];
>
> @@ -186,7 +185,7 @@ static int ceph_aes_encrypt(const void *key, int key_len,
>                 goto out_tfm;
>
>         crypto_skcipher_setkey((void *)tfm, key, key_len);
> -       memcpy(iv, aes_iv, ivsize);
> +       memcpy(iv, aes_iv, AES_BLOCK_SIZE);
>
>         skcipher_request_set_tfm(req, tfm);
>         skcipher_request_set_callback(req, 0, NULL, NULL);
> @@ -229,8 +228,7 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
>         struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
>         SKCIPHER_REQUEST_ON_STACK(req, tfm);
>         int ret;
> -       int ivsize = AES_BLOCK_SIZE;
> -       char iv[ivsize];
> +       char iv[AES_BLOCK_SIZE];
>         size_t zero_padding = (0x10 - ((src1_len + src2_len) & 0x0f));
>         char pad[16];
>
> @@ -250,7 +248,7 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
>                 goto out_tfm;
>
>         crypto_skcipher_setkey((void *)tfm, key, key_len);
> -       memcpy(iv, aes_iv, ivsize);
> +       memcpy(iv, aes_iv, AES_BLOCK_SIZE);
>
>         skcipher_request_set_tfm(req, tfm);
>         skcipher_request_set_callback(req, 0, NULL, NULL);
> @@ -294,8 +292,7 @@ static int ceph_aes_decrypt(const void *key, int key_len,
>         struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
>         SKCIPHER_REQUEST_ON_STACK(req, tfm);
>         char pad[16];
> -       int ivsize = AES_BLOCK_SIZE;
> -       char iv[16];
> +       char iv[AES_BLOCK_SIZE];
>         int ret;
>         int last_byte;
>
> @@ -310,7 +307,7 @@ static int ceph_aes_decrypt(const void *key, int key_len,
>                 goto out_tfm;
>
>         crypto_skcipher_setkey((void *)tfm, key, key_len);
> -       memcpy(iv, aes_iv, ivsize);
> +       memcpy(iv, aes_iv, AES_BLOCK_SIZE);
>
>         skcipher_request_set_tfm(req, tfm);
>         skcipher_request_set_callback(req, 0, NULL, NULL);
> @@ -363,8 +360,7 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
>         struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
>         SKCIPHER_REQUEST_ON_STACK(req, tfm);
>         char pad[16];
> -       int ivsize = AES_BLOCK_SIZE;
> -       char iv[ivsize];
> +       char iv[AES_BLOCK_SIZE];
>         int ret;
>         int last_byte;
>
> @@ -380,7 +376,7 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
>                 goto out_tfm;
>
>         crypto_skcipher_setkey((void *)tfm, key, key_len);
> -       memcpy(iv, aes_iv, ivsize);
> +       memcpy(iv, aes_iv, AES_BLOCK_SIZE);
>
>         skcipher_request_set_tfm(req, tfm);
>         skcipher_request_set_callback(req, 0, NULL, NULL);

LGTM.  You want to take it through crypto?

Thanks,

                Ilya

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
