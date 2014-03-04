From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Tue, 4 Mar 2014 23:16:31 +0100
Message-ID: <cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
References: <1393943688-24221-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
    <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
    <20140304.170050.2058599034902221847.davem@davemloft.net>
Reply-To: phoebe.buckheister@itwm.fraunhofer.de
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: phoebe.buckheister@itwm.fraunhofer.de, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:43082 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbaCDWQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 17:16:34 -0500
Received: from itwm1.itwm.fhg.de (itwm1.itwm.fhg.de [131.246.191.4])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s24MGWKB012461
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2014 23:16:32 +0100
In-Reply-To: <20140304.170050.2058599034902221847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +struct ieee802154_sechdr {
>> +	u8 sc;
>> +	u32 frame_ctr;
>> +	union {
>> +		struct {
>> +			u16 pan_id;
>> +			u16 short_addr;
>> +		} pan;
>> +		u8 hw[IEEE802154_ADDR_LEN];
>> +	} key_source;
>> +	u8 key_id;
>> +};
>> +
>> +struct ieee802154_hdr {
>> +	u16 fc;
>> +	u8 seq;
>> +	struct ieee802154_addr source;
>> +	struct ieee802154_addr dest;
>> +	struct ieee802154_sechdr sec;
>> +};
>
> You're going to have to address endianness both in these structure
> definitions and the code.
>
> For types larger than u8 you'll need to use __be16, __le16, __be32,
> __le32 etc. as appropriate.
>
> When setting/loading values, you'll need to use cpu_to_be16(),
> cpu_to_le16() etc.  as appropriate.

The intention here was to explicitly not do that, and have this
representation of the header be completely in host byte order. This is due
to the fact that an easily accessible (i.e. no bitshifts/pointer
arithmetic all over the place) representation will differ wildly from the
actual packet MAC header contents, so I went with host byte order there
instead. The header operations will convert them to/from the correct byte
order for the actual MAC header.

I see some value in being able to memcpy() to/from those fields directly
when building/reading headers, but I also think that not having to do
endianness conversion everywhere for a struct that cannot ever be a valid
header as is outweighs this.

If explicit endianness is required for this case nonetheless, I will of
course change it.
