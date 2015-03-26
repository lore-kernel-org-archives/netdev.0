From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Thu, 26 Mar 2015 17:08:05 +0300
Message-ID: <551412C5.3050804@cogentembedded.com>
References: <1427358484-16402-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vasily.isaenko@oracle.com
To: Alexey Kodanev <alexey.kodanev@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35675 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbbCZOIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:08:09 -0400
Received: by lahp7 with SMTP id p7so27453580lah.2
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 07:08:07 -0700 (PDT)
In-Reply-To: <1427358484-16402-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/26/2015 11:28 AM, Alexey Kodanev wrote:

> Regression from the following commit: 2dc49d1680.

    Please also specify that commit's summary line in parens.

> tcp_v6_fill_cb() will be called twice if socket's state changes from
> TCP_TIME_WAIT to TCP_LISTEN. That can result in control buffer data
> corruption because in the second tcp_v6_fill_cb() call it's not copying
> IP6CB(skb) anymore, but 'seq', 'end_seq', etc., so we can get weird and
> unpredictable results. Performance loss of up to 1200% has been observed
> in LTP/vxlan03 test.

> This can be fixed by copying inet6_skb_parm to the beginning of 'cb'
> only if xfrm6_policy_check() and tcp_v6_fill_cb() are going to be
> called again.

> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

[...]

WBR, Sergei
