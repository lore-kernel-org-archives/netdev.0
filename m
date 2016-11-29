From: Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] ethernet :mellanox :mlx4: Replace pci_pool_alloc by pci_pool_zalloc
Date: Tue, 29 Nov 2016 13:55:52 +0530
Message-ID: <CAFqt6za4QG30cArRE+F2DNS5VnpLbkP7jMGeauBRjTqMJwna2A@mail.gmail.com>
References: <20161129065931.GA3245@gnr743-HP-ZBook-15> <CAFqt6zYzUyZ__7iVH3LwhGzeU7RN59-md4rcmwngRZW_ahDeAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114abc8032362505426c562b
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rameshwar Sahu <sahu.rameshwar73-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFqt6zYzUyZ__7iVH3LwhGzeU7RN59-md4rcmwngRZW_ahDeAQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--001a114abc8032362505426c562b
Content-Type: text/plain; charset=UTF-8

While sending the patch using "mutt" , alignment is getting changed.
In original patch file alignment is proper and
I have tested the patch with "checkpatch.pl". Attach is the original patch file.

I am using mutt -H < patch-file>

Any suggestion will be helpful?

On Tue, Nov 29, 2016 at 12:55 PM, Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Please ignore this v2 patch.
>
> On Tue, Nov 29, 2016 at 12:29 PM, Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> In mlx4_alloc_cmd_mailbox(), pci_pool_alloc() followed by memset will be
>> replaced by pci_pool_zalloc().
>>
>> Signed-off-by: Souptick joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> v2:
>>   - Address comment from sergei
>>     Alignment was not proper
>>
>>  drivers/net/ethernet/mellanox/mlx4/cmd.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> index e36bebc..96cdf9a 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> @@ -2679,14 +2679,13 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
>>         if (!mailbox)
>>                 return ERR_PTR(-ENOMEM);
>>
>> -       mailbox->buf = pci_pool_alloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
>> -                                     &mailbox->dma);
>> +       mailbox->buf = pci_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
>> +                                      &mailbox->dma);
>>         if (!mailbox->buf) {
>>                 kfree(mailbox);
>>                 return ERR_PTR(-ENOMEM);
>>         }
>>
>> -       memset(mailbox->buf, 0, MLX4_MAILBOX_SIZE);
>>
>>         return mailbox;
>>  }
>> --
>> 1.9.1
>>

Regards
Souptick

--001a114abc8032362505426c562b
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-ethernet-mellanox-mlx4-Replace-pci_pool_alloc-by-pci.patch"
Content-Disposition: attachment;
	filename="0001-ethernet-mellanox-mlx4-Replace-pci_pool_alloc-by-pci.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iw38l49j0

RnJvbSAzNjIxZWFjOTJkMjcxMzMyZWNjOTViNmYwOWNlMjViN2M2ODQ2MTM3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTb3VwdGljayBKb2FyZGVyIDxqcmRyLmxpbnV4QGdtYWlsLmNv
bT4KRGF0ZTogVHVlLCAyOSBOb3YgMjAxNiAxMjoxNTozOSArMDUzMApTdWJqZWN0OiBbUEFUQ0gg
djJdIGV0aGVybmV0IDptZWxsYW5veCA6bWx4NDogUmVwbGFjZSBwY2lfcG9vbF9hbGxvYyBieQog
cGNpX3Bvb2xfemFsbG9jCgpJbiBtbHg0X2FsbG9jX2NtZF9tYWlsYm94KCksIHBjaV9wb29sX2Fs
bG9jKCkgZm9sbG93ZWQgYnkgbWVtc2V0IHdpbGwgYmUKcmVwbGFjZWQgYnkgcGNpX3Bvb2xfemFs
bG9jKCkuCgpTaWduZWQtb2ZmLWJ5OiBTb3VwdGljayBqb2FyZGVyIDxqcmRyLmxpbnV4QGdtYWls
LmNvbT4KLS0tCnYyOgogIC0gQWRkcmVzcyBjb21tZW50IGZyb20gc2VyZ2VpCiAgICBBbGlnbm1l
bnQgd2FzIG5vdCBwcm9wZXIKCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHg0L2Nt
ZC5jIHwgNSArKy0tLQogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlv
bnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHg0L2Nt
ZC5jIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvbWVsbGFub3gvbWx4NC9jbWQuYwppbmRleCBlMzZi
ZWJjLi45NmNkZjlhIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9t
bHg0L2NtZC5jCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDQvY21kLmMK
QEAgLTI2NzksMTQgKzI2NzksMTMgQEAgc3RydWN0IG1seDRfY21kX21haWxib3ggKm1seDRfYWxs
b2NfY21kX21haWxib3goc3RydWN0IG1seDRfZGV2ICpkZXYpCiAJaWYgKCFtYWlsYm94KQogCQly
ZXR1cm4gRVJSX1BUUigtRU5PTUVNKTsKIAotCW1haWxib3gtPmJ1ZiA9IHBjaV9wb29sX2FsbG9j
KG1seDRfcHJpdihkZXYpLT5jbWQucG9vbCwgR0ZQX0tFUk5FTCwKLQkJCQkgICAgICAmbWFpbGJv
eC0+ZG1hKTsKKwltYWlsYm94LT5idWYgPSBwY2lfcG9vbF96YWxsb2MobWx4NF9wcml2KGRldikt
PmNtZC5wb29sLCBHRlBfS0VSTkVMLAorCQkJCSAgICAgICAmbWFpbGJveC0+ZG1hKTsKIAlpZiAo
IW1haWxib3gtPmJ1ZikgewogCQlrZnJlZShtYWlsYm94KTsKIAkJcmV0dXJuIEVSUl9QVFIoLUVO
T01FTSk7CiAJfQogCi0JbWVtc2V0KG1haWxib3gtPmJ1ZiwgMCwgTUxYNF9NQUlMQk9YX1NJWkUp
OwogCiAJcmV0dXJuIG1haWxib3g7CiB9Ci0tIAoxLjkuMQoK
--001a114abc8032362505426c562b--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
