From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: Why do we need MSG_SENDPAGE_NOTLAST?
Date: Thu, 4 May 2017 17:03:24 +0000
Message-ID: <VI1PR0502MB2957F149F915013F6813559FD4EA0@VI1PR0502MB2957.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: tls-fpga-sw-dev <tls-fpga-sw-dev@mellanox.com>,
        Dave Watson <davejwatson@fb.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0041.outbound.protection.outlook.com ([104.47.2.41]:5099
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751170AbdEDRD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 13:03:27 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't understand the need for MSG_SENDPAGE_NOTLAST and I'm hoping someone=
 can enlighten me.

According to commit 35f9c09 ('tcp: tcp_sendpages() should call tcp_push() o=
nce'):
"We need to call tcp_flush() at the end of the last page processed in
tcp_sendpages(), or else transmits can be deferred and future sends
stall."

I don't understand why we need to differentiate between the user setting MS=
G_MORE=20
and splice indicating that more data is going to be sent.
if the user passed MSG_MORE and didn't push any extra data, isn't it the us=
ers fault?=20
Do we need it because poorly written applications were broken when=20
MSG_MORE was added to tcp_sendpage? Or is there a deeper reason?

The reason I'm asking is that we are working on a kernel TLS implementation=
=20
and I would like to know if we can coalesce multiple tls_sendpage calls wit=
h MSG_MORE into a single
tls record or whether we must push out the record as soon as MSG_SENDPAGE_N=
OTLAST is cleared?

Thanks,
Ilya
