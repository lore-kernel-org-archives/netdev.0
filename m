From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Thu, 07 Jan 2016 00:26:37 +0100
Message-ID: <87vb76b87m.fsf@nemi.mork.no>
References: <20160106.163309.111867454969344145.davem@davemloft.net>
	<1452121966.24575.52.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57149 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752230AbcAFX0y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:26:54 -0500
In-Reply-To: <1452121966.24575.52.camel@perches.com> (Joe Perches's message of
	"Wed, 06 Jan 2016 15:12:46 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:
> On Wed, 2016-01-06 at 16:33 -0500, David Miller wrote:
>> A repeating pattern in drivers has become to use OF node information
>> and, if not found, platform specific host information to extract the
>> ethernet address for a given device.
> []
>> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice=
=2Eh
> []
>> @@ -485,3 +487,32 @@ static int __init eth_offload_init(void)
>> =C2=A0}
>> =C2=A0
>> =C2=A0fs_initcall(eth_offload_init);
>> +
>> +unsigned char * __weak arch_get_platform_mac_address(void)
>> +{
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return NULL;
>
> WARN_ON_ONCE ?

That would prevent a driver from using this with additional fallback
methods.  For what reason?

I don't have a specific usecase, but I can imagine drivers falling back
to e.g a random address without wanting to be noisy about it.


Bj=C3=B8rn
