From: "Julius Volz" <juliusv@google.com>
Subject: Re: Sending big Netlink messages to userspace
Date: Wed, 25 Jun 2008 20:56:35 +0200
Message-ID: <f4845fc0806251156m5c6405c9w65cd126c1e5551ce@mail.gmail.com>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>
	 <f4845fc0806241118u397a17e3qbe09f5d04a7e5035@mail.gmail.com>
	 <4861282C.4000208@trash.net> <20080625104401.GJ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, netdev@vger.kernel.org,
	"Vince Busam" <vbusam@google.com>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:18279 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbYFYS4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 14:56:41 -0400
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m5PIubjl029763
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 19:56:38 +0100
Received: from yx-out-1718.google.com (yxp4.prod.google.com [10.190.4.196])
	by zps35.corp.google.com with ESMTP id m5PIuat5026304
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 11:56:36 -0700
Received: by yx-out-1718.google.com with SMTP id 4so697717yxp.42
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 11:56:35 -0700 (PDT)
In-Reply-To: <20080625104401.GJ20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2008, Thomas Graf wrote:
> libnl initializes the buffer size to the size of a page. The value
> can be overwritten by calling nl_set_buffer_size(socket, rx, tx)

Thanks, I missed that. Though now I won't need that anymore as I got
the dump working!

> Yes, that's how it's intended to work. You can fill until one of the
> nla_put variantes aborts and starting trimming off what you've added
> already using the nla_nest_cancel() methods until you reach a point
> where you can safely cut your stream of attributes. So far we typically
> made sure that this barrier is on netlink message level but is no
> requirement. You may split a list into several messages you just
> have to make sure that you call nla_nest_end() and nlmsg_end() properly
> before you send the message.

Ok, I did exactly that! Took me a while to figure out all of the
necessary quirks (including userland), but now it works! :)

So userspace now gets one callback invocation per part of a multipart
message. I guess it's not possible to aggregate the data into just one
callback invocation?

Thanks again!
Julius

-- 
Google Switzerland GmbH
