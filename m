From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Tue, 22 Jul 2008 08:56:04 -0400
Message-ID: <6599ad830807220556i3c2afc77j2e68d7179830b3ff@mail.gmail.com>
References: <Pine.LNX.4.64.0807212100580.1760@ranjit.corp.google.com>
	 <4885B7DD.7070507@trash.net>
	 <6599ad830807220514m5afea0fcsb99bf2e95f401c36@mail.gmail.com>
	 <4885D72A.1060106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ranjit Manomohan" <ranjitm@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:33867 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbYGVM4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 08:56:15 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out3.google.com with ESMTP id m6MCu5cG027155
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 13:56:06 +0100
Received: from wa-out-1112.google.com (wafk22.prod.google.com [10.114.187.22])
	by zps78.corp.google.com with ESMTP id m6MCu4TV009506
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 05:56:05 -0700
Received: by wa-out-1112.google.com with SMTP id k22so991321waf.20
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 05:56:04 -0700 (PDT)
In-Reply-To: <4885D72A.1060106@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 8:48 AM, Patrick McHardy <kaber@trash.net> wrote:
>
> Using skb->priority for classification would be fine, but it would
> probably interfere with the default initialization to sk->sk_priority.

Well internally we just overloaded sk->sk_priority to be the classid,
and let skb->priority be inherited from that.

>
>> Regarding skb->sk->sk_cgroup_classid, is it always the case that the
>> original sk is still available when we're making traffic control
>> decisions? I'd thought that there were cases (e.g. cloning skbs in the
>> TCP retransmit path) where the pointer to the original sk is lost.
>
> After cloning, TCP sets the owner of the skb to the socket, so
> that should work fine.
>

OK, so maybe we don't need a per-skb field after all.

Paul
