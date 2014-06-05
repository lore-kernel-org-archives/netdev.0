From: Cong Wang <cwang@twopensource.com>
Subject: Re: Bug 75571
Date: Wed, 4 Jun 2014 17:27:17 -0700
Message-ID: <CAHA+R7N74QODqvWyvP1gHsK2dm_Zgrkq0+k8LZnqnA8EqnMOZw@mail.gmail.com>
References: <1401085231.1775.9.camel@anpws>
	<CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
	<1401870692.29664.1.camel@anpws>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Alex <d77190@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:37218 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbaFEA1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 20:27:18 -0400
Received: by mail-qg0-f54.google.com with SMTP id q108so425180qgd.41
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 17:27:18 -0700 (PDT)
In-Reply-To: <1401870692.29664.1.camel@anpws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 4, 2014 at 1:31 AM, Alex <d77190@mail.ru> wrote:
>> Could you try the following patch? We need to call skb_cow_head() before
>> skb_push().
> This patch solves problem, no panic or any error messages.
> Thank you.
>

Thanks for testing!

Thinking a bit more, the question is why
skb_push(skb->dev->hard_header_len) is not correct here? It looks
like we don't calculate tunnel->dev->hard_header_len correctly. But
ipip_tunnel_bind_dev() should do the right thing less your setup is not
correct, in that case your ipip tunnel should not receive any packet.
We should be safe.

Which is the interface routing to 192.168.18.17 on your system? Which
driver does it use?
