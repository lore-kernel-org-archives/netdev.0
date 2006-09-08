From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Fri, 8 Sep 2006 17:10:08 +0400
Message-ID: <200609081710.09124.dim@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru> <45004799.70000@sw.ru> <20060907172759.GB25118@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kirill Korotaev <dev@sw.ru>, devel@openvz.org,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:56205 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1751081AbWIHNLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 09:11:45 -0400
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060907172759.GB25118@MAIL.13thfloor.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 07 September 2006 21:27, Herbert Poetzl wrote:
> well, who said that you need to have things like RAW sockets
> or other protocols except IP, not to speak of iptable and
> routing entries ...
>
> folks who _want_ full network virtualization can use the
> more complete virtual setup and be happy ...
Let's think about how to implement this.
As I understood VServer's design, your proposal is to split CAP_NET_ADMIN to
multiple capabilities and use them if required. So, for your light-weight 
container it is enough to implement context isolation for protected by 
CAP_NET_IP capability (for example) code and put 'if (!capable(CAP_NET_*))' 
checks to all other places. But this could be easily implemented over OpenVZ 
code by CAP_VE_NET_ADMIN split.

So, the question is:
Could you point out the places in Andrey's implementation of network 
namespaces, which prevents you to add CAP_NET_ADMIN separation later?

-- 
Thanks,
Dmitry.
