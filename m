From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/8] ieee802154: add address struct with proper
 endiannes and some operations
Date: Fri, 14 Mar 2014 16:00:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DDDE4@AcuExch.aculab.com>
References: <1394810613-5657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
 <1394810613-5657-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Phoebe Buckheister' <phoebe.buckheister@itwm.fraunhofer.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56498 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754791AbaCNQBm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 12:01:42 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23385-10 for <netdev@vger.kernel.org>;
 Fri, 14 Mar 2014 16:01:39 +0000 (GMT)
In-Reply-To: <1394810613-5657-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister
> Add a replacement ieee802154_addr struct with proper endianness on
> fields. Short address fields are stored as __le16 as on the network,
> extended (EUI64) addresses are __le64 as opposed to the u8[8] format
> used previously. This disconnect with the netdev address, which is
> stored as big-endian u8[8], is intentional.
...
> +struct ieee802154_addr {
> +	u8 mode;
> +	__le16 pan_id;
> +	union {
> +		__le16 short_addr;
> +		__le64 extended_addr;
> +	};
> +};

There is a lot of padding in there - especially on 64bit systems.
You didn't make it clear where the above is used, but if it is
passed to userspace I'd add explicit padding fields to ensure
that the alignment is the same on all (sensible) architectures.

	David
