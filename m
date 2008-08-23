From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4 2.6.28] cxgb3 - manage a private ip address for iSCSI
Date: Sat, 23 Aug 2008 14:55:20 +1000
Message-ID: <20080823045520.GA4759@gondor.apana.org.au>
References: <200808221838.m7MIcW6a004400@localhost.localdomain> <20080822120851.c45a90f2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karen Xie <kxie@chelsio.com>, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080822120851.c45a90f2.akpm@linux-foundation.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2008 at 07:08:51PM +0000, Andrew Morton wrote:
>
>> +static ssize_t iscsi_ipaddr_attr_store(struct device *d,
>> +                                    const char *buf, size_t len)
>> +{
>> +     struct port_info *pi = netdev_priv(to_net_dev(d));
>> +     __be32 a = 0;
> 
> There's not really any need to use __be32 in kernel code.  Plain old
> be23 is fine.

Sorry but where is be32 defined? I couldn't find it in linux/types.h.

Perhaps we should resurrect this patch from 2005?

[PATCH] Add be*/le* types without underscores

I've seen a number of patches that have started to use the __le*/__be*
types within the kernel.  Nice as they are, the underscores are really
a bit of an eye sore.  Since there seems to be no name conflict within
the kernel, why don't we use them without the underscores like just as
we do with types like u32?

Here is a patch to do just that.  I've verified that there are no
conflicts by grepping the current git tree and then building it with
the patch.

Of course userspace won't see them since they're protected by
#ifdef __KERNEL__.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/fs/ntfs/types.h b/fs/ntfs/types.h
index 8c8053b..79b44c7 100644
--- a/fs/ntfs/types.h
+++ b/fs/ntfs/types.h
@@ -25,9 +25,6 @@
 
 #include <linux/types.h>
 
-typedef __le16 le16;
-typedef __le32 le32;
-typedef __le64 le64;
 typedef __u16 __bitwise sle16;
 typedef __u32 __bitwise sle32;
 typedef __u64 __bitwise sle64;
diff --git a/include/linux/types.h b/include/linux/types.h
index d4a9ce6..61747dc 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -189,6 +189,15 @@ typedef __u16 __bitwise __sum16;
 typedef __u32 __bitwise __wsum;
 
 #ifdef __KERNEL__
+typedef __le16 le16;
+typedef __be16 be16;
+typedef __le32 le32;
+typedef __be32 be32;
+#if defined(__GNUC__)
+typedef __le64 le64;
+typedef __be64 be64;
+#endif
+
 typedef unsigned __bitwise__ gfp_t;
 
 #ifdef CONFIG_RESOURCES_64BIT

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
