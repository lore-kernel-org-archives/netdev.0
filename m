From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ip: report the original address of ICMP messages
Date: Tue, 23 Jun 2015 21:55:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506232123320.1804@ja.home.ssi.bg>
References: <1435037679-2304-1-git-send-email-ja@ssi.bg> <CA+FuTSeza4ZhCUPoL9hLuZzNHAQf79mSBi9EvMvx3mK58A2RRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44714 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932130AbbFWSzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 14:55:25 -0400
In-Reply-To: <CA+FuTSeza4ZhCUPoL9hLuZzNHAQf79mSBi9EvMvx3mK58A2RRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 23 Jun 2015, Willem de Bruijn wrote:

> The ping utility from iputils relies on cmsg IP_RECVERR to get
> the source address on icmp errors, not on msg_name, so that
> worked for me both before and after applying the patch. I used
> `ping -t 2 $hostname` to trigger a TTL exceeded. Perhaps you used
> a different tool or test? In any case, the change looks fine to me.
> Thanks for preparing the patch.


# rpm -qf `which ping`
iputils-20140519-1.fc20.i686

	It is using IP_RECVERR and may be relying only on
original address returned in msg_name from MSG_ERRQUEUE.
May be it ignores the error if original address is missing
or is different.

	I didn't checked the ping source but I noticed that
it does not print anything on the read from raw socket, only
on IP_RECVERR. I noticed it when my network connection
failed. The incoming ICMP packet from my router was
DEST_UNREACH(type=3), HOST_UNREACH(code=1) but simple
REJECT rule in OUTPUT can do the same.

Regards

--
Julian Anastasov <ja@ssi.bg>
