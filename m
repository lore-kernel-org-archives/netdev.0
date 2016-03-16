From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH ethtool 2/3] Add IPv6 support to NFC
Date: Wed, 16 Mar 2016 14:53:43 +0000
Message-ID: <56E97377.4030400@solarflare.com>
References: <56C1E73A.5090603@solarflare.com>
 <56C1E7EC.8020700@solarflare.com> <1457887406.3331.31.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:53103 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934858AbcCPPA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 11:00:58 -0400
In-Reply-To: <1457887406.3331.31.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/03/16 16:43, Ben Hutchings wrote:
> On Mon, 2016-02-15 at 14:59 +0000, Edward Cree wrote:
>> Signed-off-by: Edward Cree <ecree@solarflare.com>
> [...]
>> @@ -950,6 +1154,19 @@ static int rxclass_get_mask(char *str, unsigned char *p,
>>                 *(__be32 *)&p[opt->moffset] = ~val;
>>                 break;
>>         }
>> +       case OPT_IP6: {
>> +               __be32 val[4];
>> +               int i;
>> +               err = rxclass_get_ipv6(str, val);
>> +               if (err)
>> +                       return -1;
>> +               for (i = 0; i < 4; i++) {
>> +                       ((__be32 *)&p[opt->offset])[i] = val[i];
>> +                       if (opt->moffset >= 0)
>> +                               ((__be32 *)&p[opt->moffset])[i] = ~val[i];
> This pointer arithmetic looks terrible.  I think memcpy() would be much
> clearer here.
I've changed the version in rxclass_get_val to use memcpy() (and memset() the
mask).  Unfortunately, we can't do that here, because we need to complement
the mask valueas we go, and afaik there's no library function to copy-and-
complement a byte array.
Glibc does, however, have a function memfrob(), which XORs every byte of an
arraywiththe constant 42.  Useful feature, that.
On the other hand, the quoted code is still wrong because it's also writing
throughopt->offset and checking for opt->moffset>= 0, both daft copy-and-
paste errors onmypart.  Will fix in next version.
> I won't apply patches labelled as "confidential".  You need to stop
> including this nonsense in your public messages (I thought you fixed
> this once before).
In theory it's been fixed harder now - please let me know if not.

-Ed
