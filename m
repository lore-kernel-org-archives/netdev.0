From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/7] net: bluetooth: compact struct bt_skb_cb
 by converting boolean fields to bit fields
Date: Thu, 26 Feb 2015 11:31:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAEE8D0@AcuExch.aculab.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
 <1424916612-744-3-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "willemb@google.com" <willemb@google.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"shmulik.ladkani@gmail.com" <shmulik.ladkani@gmail.com>,
	"marcel@holtmann.org" <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eyal Birger' <eyal.birger@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:54699 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100AbbBZLcE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 06:32:04 -0500
In-Reply-To: <1424916612-744-3-git-send-email-eyal.birger@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger
> On 64 bit systems, struct bt_skb_cb size is padded by 6 bytes in order
> to reach 8 byte alignment.
> Convert boolean fields force_active, incoming and req_start to bit fields
> in order to eliminate the padding.
...
> +++ b/include/net/bluetooth/bluetooth.h
...
>  struct bt_skb_cb {
>  	__u8 pkt_type;
> -	__u8 incoming;
>  	__u16 opcode;
>  	__u16 expect;
> -	__u8 force_active;
> -	bool req_start;
> +	__u8 force_active:1;
> +	__u8 incoming:1;
> +	__u8 req_start:1;
>  	u8 req_event;
>  	hci_req_complete_t req_complete;
>  	struct l2cap_chan *chan;

You've generated some pad bytes, best to put everything on its natural alignment.
The old version had req_complete at offset 9, the new one at offset 8.
Not sure how this removes 6 bytes of pad.

	David
