From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP and reordering
Date: Tue, 27 Nov 2012 09:05:30 -0800
Message-ID: <50B4F2DA.8020206@hp.com>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Saku Ytti <saku@ytti.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:24857 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122Ab2K0RFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 12:05:32 -0500
In-Reply-To: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/2012 01:32 AM, Saku Ytti wrote:
> Today due to fast retransmit performance on links which cause
> reordering is appalling.
>
> Is it too esoteric situation to handle gracefully? Couldn't we
> maintain 'reorder' counter in socket, which is increment when we get
> two copies of same packet after duplicate ack, if this counter is
> sufficiently high in relation to packet loss, we could start delaying
> duplicate acks as we'd expect to receive the sequence very soon.

Packet reordering is supposed to be the exception, not the rule.  Links 
which habitually/constantly introduce reordering are, in my opinion, 
broken.  Optimizing for them would be optimizing an error case.

That said, there is net.ipv4.tcp_reordering which you can increase from 
the default of three to desensitize TCP to such broken links.  That will 
though be on the sending rather than receiving side.

rick jones
