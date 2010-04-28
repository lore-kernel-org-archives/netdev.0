From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 2/4] [RFC] Add sock_create_kern_net()
Date: Tue, 27 Apr 2010 22:18:21 -0400
Message-ID: <4BD79AED.9030507@hp.com>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>	<1272034539-19899-3-git-send-email-danms@us.ibm.com> <20100427.171844.77354120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: danms@us.ibm.com, containers@lists.osdl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:21928 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab0D1CSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 22:18:24 -0400
In-Reply-To: <20100427.171844.77354120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Dan Smith <danms@us.ibm.com>
> Date: Fri, 23 Apr 2010 07:55:37 -0700
> 
>> This helper allows kernel routines to create a socket in a given netns,
>> instead of forcing it to the initial or current one.
>>
>> I know this seems like it's violating the netns boundary.  The intended
>> use (as in the following patches) is specifically when talking to RTNETLINK
>> in another netns for the purposes of creating or examining resources there.
>> It is expected that this will be used for that sort of transient socket
>> creation only.  In other words:
> 
> If you can create netlink sockets in a remote NS you can also make
> changes there, and the whole point is to disallow changes.
> 
> So maybe you won't be making changes, but others will think about
> using this and doing so.
> 
> At a high level, I think this is a really bad idea, so I won't be
> applying this, sorry.

What this is changed to be a socket option or ioctl or some other mechanism
that allows one to move an existing unbound, unconnected socket to another
namespace?

This way, we do not modify the namespace directly, but still have ability
to move sockets into it for required communication.

In my mind moving a socket is someone similar to moving an interface to a
namespace.  You just moving a required resource.

Thanks
-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
