From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH Resend] core: should call pskb_expand_head if skb header
 is cloned in skb_gso_segment in rx path
Date: Tue, 02 Apr 2013 20:32:47 +0800
Message-ID: <1364905967.22165.4.camel@cr0>
References: <1364783861-3363-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755897Ab3DBMcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 08:32:53 -0400
In-Reply-To: <1364783861-3363-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-01 at 10:37 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 12b0004d1d1 (adjust skb_gso_segment() for calling in rx path) tries to kill warnings
> by checking if ip_summed is CHECK_NONE or not in rx path, since if skb_gso_segment()
> is called on rx path, and ->ip_summed has different meaning.
> 
> but this maybe break skb if skb header is cloned, and not expand the header, since when
> step into skb_mac_gso_segment(), which will still check ip_summed with CHECKSUM_PARTIAL,
> then do gso_send_check(). and after __skb_gso_segment() in queue_gso_packets() of
> openvswitch, queue_userspace_packet() still checks ip_summed with CHECKSUM_PARTIAL,
> and do checksum.
> 
> so I think it is enough to ignore the warning in rx path.
> 

Did you see any bogus warning triggered by it?

BTW, please Cc all the people involved in the original commit you
mentioned above.
