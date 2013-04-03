From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH Resend] core: should call pskb_expand_head if skb header
 is cloned in skb_gso_segment in rx path
Date: Wed, 3 Apr 2013 08:51:25 +0800
Message-ID: <CAJFZqHxn77yUpGkOUzywVR7wg2_L8tFaLNrFyaauuLWPJsQUHQ@mail.gmail.com>
References: <1364783861-3363-1-git-send-email-roy.qing.li@gmail.com>
	<1364905967.22165.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, jesse@nicira.com, pshelar@nicira.com,
	herbert@gondor.apana.org.au, edumazet@google.com
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:63043 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756493Ab3DCAv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 20:51:26 -0400
Received: by mail-vc0-f172.google.com with SMTP id hr11so1108535vcb.3
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 17:51:25 -0700 (PDT)
In-Reply-To: <1364905967.22165.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 No, I just read and analyze it, and think it is bogus.

2013/4/2 Cong Wang <amwang@redhat.com>:
> On Mon, 2013-04-01 at 10:37 +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> 12b0004d1d1 (adjust skb_gso_segment() for calling in rx path) tries to kill warnings
>> by checking if ip_summed is CHECK_NONE or not in rx path, since if skb_gso_segment()
>> is called on rx path, and ->ip_summed has different meaning.
>>
>> but this maybe break skb if skb header is cloned, and not expand the header, since when
>> step into skb_mac_gso_segment(), which will still check ip_summed with CHECKSUM_PARTIAL,
>> then do gso_send_check(). and after __skb_gso_segment() in queue_gso_packets() of
>> openvswitch, queue_userspace_packet() still checks ip_summed with CHECKSUM_PARTIAL,
>> and do checksum.
>>
>> so I think it is enough to ignore the warning in rx path.
>>
>
> Did you see any bogus warning triggered by it?
>
> BTW, please Cc all the people involved in the original commit you
> mentioned above.
>
>
