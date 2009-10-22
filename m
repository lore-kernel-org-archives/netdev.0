From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Thu, 22 Oct 2009 06:53:03 -0400
Message-ID: <4AE0398F.4040503@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>	<1256115421-12714-9-git-send-email-gilad@codefidence.com>	<4ADED6FA.2030502@gmail.com>	<4ADEE119.7020803@codefidence.com>	<4ADF616B.1090405@gmail.com> <20091022003245.5cd4885c.billfink@mindspring.com> <4ADFE635.4020109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:42610 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924AbZJVKxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 06:53:03 -0400
Received: by yxe17 with SMTP id 17so6849118yxe.33
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 03:53:07 -0700 (PDT)
In-Reply-To: <4ADFE635.4020109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Absolutely, global setting is a must when an admin wants a quick path.
> 
> The more flexible would be to have two bits per route, plus
> 2 bits on the global configuration.
> 
> global conf:
> 00 : timestamps OFF, unless a route setting is not 00
> 01 : timestamps ON, unless a route setting is not 00
> 10 : Force timestamps OFF, ignore route settings (emergency sysadmin request)
> 11 : Force timestamps ON, ignore route settings 
> 
> Route settings (used *only* if global setting is 0Y)
> 00 : global conf is used
> 01 : Force timestamps being OFF for this route
> 10 : Force timestamps being ON for this route
> 11 : complement global conf
> 
Nice!  Seems to have all the bases covered.  For consistency, I'd swap the
latter values (although I doubt complement will have much use):

00 : global conf is used
01 : complement global conf
10 : Timestamps OFF for this route
11 : Timestamps ON for this route

And the documentation should make it clear that global 10 and 11 override
per route 10 and 11.
