From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Wed, 23 Sep 2015 10:09:57 +0200
Message-ID: <20150923080957.GB29680@pox.localdomain>
References: <cover.1442936392.git.jbenc@redhat.com>
 <87zj0d92ba.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37396 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbbIWIKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 04:10:00 -0400
Received: by wicfx3 with SMTP id fx3so57127799wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 01:09:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87zj0d92ba.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/15 at 11:39pm, Eric W. Biederman wrote:
> What distinguishes a skb received from a tunnel as opposed to a skb
> received on from a network device is that a skb recevied on a tunnel
> has a socket.
> 
> I could be easily missing something but couldn't you look at skb->sk
> on the input path and if a socket is present use the socket to compute
> the outgoing route?
> 
> I expect it would just need to be something like:
> dst = sk_dst_check(sk, 0);

If you are talking about the UDP socket then that socket would cache
the underlay route corresponding to the outer header. Jiri is looking
for the outer header route to derive tunnel parameters from.
