From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: TCP MD5 and socket accept
Date: Thu, 26 Jun 2008 07:46:59 -0700
Message-ID: <396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
References: <20080625225657.61e1b29b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"=?UTF-8?B?5ZCJ6Jek6Iux5piO?=" <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:27676 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbYFZOrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 10:47:01 -0400
Received: by rv-out-0506.google.com with SMTP id k40so61394rvb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 07:47:01 -0700 (PDT)
In-Reply-To: <20080625225657.61e1b29b@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2008 at 10:56 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> What will break if tcp_create_openreq_child was fixed to copy md5_info if
> present?
>
> This all comes about because right now using Quagga a Linux to Linux
> works with TCP MD5. But a Linux to Cisco connection fails if using
> TCP MD5.

I'll have a look at this later today but, as you say, Linux to Linux
works, and getting the key wrong certainly breaks it (and without
setsockopt on the child, I believe). So some MD5 information is
getting copied from listening sockets to children.

Also note the MD5 on Linux is pretty badly broken in the face of
packet loss at the moment. I have patches floating around to fix it,
but not in any trees yet.


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
