From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Wed, 5 Mar 2014 20:15:56 +0100
Message-ID: <7c9810ea21990e7e239b101f548818f7.squirrel@webmail.itwm.fhg.de>
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
Received: from mailgw1.uni-kl.de ([131.246.120.220]:49224 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbaCETQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 14:16:14 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s25JFv2Z019426
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2014 20:16:13 +0100
In-Reply-To: <20140304.170050.2058599034902221847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> Date: Tue,  4 Mar 2014 15:34:45 +0100
>
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

The fc field in struct ieee802154_hdr is a bitfield with many subfields,
the sc field of struct ieee802154_sec_hdr is also a bitfield. Would it be
acceptable to represent them as bitfields in the header struct? I expect
the code to be just as efficient in every respect, but more readable since
we wouldn't need explicit shifts and masks everywhere.
