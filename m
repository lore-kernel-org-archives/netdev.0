From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: baycom_ser_fdx - fixed under 2.6
Date: Mon, 28 Jul 2008 13:32:42 +0300
Message-ID: <20080728103242.GN3820@mea-ext.zmailer.org>
References: <alpine.DEB.1.10.0807191042050.21295@tombstone.paradise.gen.nz> <4885A8F6.7090109@free.fr> <488D4096.5000906@xnet.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pidoux <f6bvp@free.fr>, David Robb <ender@paradise.gen.nz>,
	linux-hams@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Peter Mallett <zl2bau@xnet.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:42804 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849AbYG1Kcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 06:32:46 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S3541494AbYG1Kcm (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Mon, 28 Jul 2008 13:32:42 +0300
Content-Disposition: inline
In-Reply-To: <488D4096.5000906@xnet.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 28, 2008 at 03:44:22PM +1200, Peter Mallett wrote:
> Pidoux wrote:
>> Hi,
....
>> 73 de Bernard, f6bvp
>>
>> --- a/drivers/net/hamradio/hdlcdrv.c    2008-07-22 10:40:20.000000000 +0200
>> +++ b/drivers/net/hamradio/hdlcdrv.c    2008-07-22 10:42:13.000000000 +0200
>> @@ -88,6 +88,7 @@
>>  static inline void append_crc_ccitt(unsigned char *buffer, int len)
>>  {
>>       unsigned int crc = crc_ccitt(0xffff, buffer, len) ^ 0xffff;
>> +    buffer += len;
>>      *buffer++ = crc;
>>      *buffer++ = crc >> 8;
>>  }
....
> Hi,
>
>    The Baycom MoDem problem is one I have battled for quite a while here.
>
> How do I apply this patch to my Ubuntu 2.6.20-17-generic kernel.
>
> I have the linux-source-2.6.20-2.6.20 source so which file do I apply  
> the patch too ?

Officially:

  patch -p1 < patch.text

Easier for you:

 - pick editor that you know how to use (nano, vi, emacs, joe, jove...)
 - edit file  drivers/net/hamradio/hdlcdrv.c
   - locate function  append_crc_ccitt
   - add missing line

> Then I need to recompile it ?

Yes.

Better would be to rebuild your kernel runtime in distribution specific
way -- which I do not know for Ubuntu.


> Would this bug also affect the SCC Baycom card ?

No.  It does HDLC framing in hardware.

> Regards ..... Peter

73 de Matti, OH2MQK
