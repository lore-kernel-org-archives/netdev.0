From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] SNMPv2 udpInDatagrams counter error
Date: Mon, 31 Jul 2006 07:21:15 -0400
Message-ID: <1154344876.4239.7.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:56978 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751502AbWGaKOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 06:14:33 -0400
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change does not effect to tcpdump, only let UDP filter can not 
received UDP datagrams with checksum error. It is not a good idea, but
I think is the best way to resolve this problem. If you want to capture
error UDP packet, you can used tcpdump.

On Monday 31 July 2006 04:57, Gerrit Renker wrote:
> Hi,
>
> |  if (!sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
> |
> |  IPv6 doesn't do this, so I think delete condition 'sk->sk_filter'
is
> | better. Do you think so?
>
> I think the sk->sk_filter is there for a good reason. If you delete
it,
> that routine is forced to always compute UDP checksums, even if the
only
> receiving application is a tcpdump process. I may be wrong here, but I
> think that deleting the sk_filter statement is not at a good idea.
>
> The other alternatives discussed (afaik) so far were:
>
> 1) Move the increment of UDP_MIB_INDATAGRAMS from udp_queue_rcv_skb()
to
> udp_recvmsg() (first patch uploaded to 
> http://bugzilla.kernel.org/show_bug.cgi?id=6660). This was discussed:
not a
> good idea, since in-kernel applications may use the data_ready handler
> rather than udp_recvmsg().
>
> 2) Decrement UDP_MIB_INDATAGRAMS in udp_recvmsg() when the checksum
turns
> out to be wrong (second patch uploaded to above address). This would
be a
> fix to the problem you are stating, it also solves the problem of
missing
> out the data_ready handlers in (1), and was suggested earlier on this
> mailing list.

