From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] netlink: support setting devgroup parameters
Date: Mon, 10 Jan 2011 08:14:33 -0500
Message-ID: <1294665273.6063.292.camel@mojatatu>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
	 <1294659524-22509-4-git-send-email-ddvlad@rosedu.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:36226 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719Ab1AJNOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 08:14:40 -0500
Received: by yib18 with SMTP id 18so5272016yib.19
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 05:14:39 -0800 (PST)
In-Reply-To: <1294659524-22509-4-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nice - short and sweet.

IMO: I dont think you need this new attribute, IFLA_GROUP
should suffice...
You can use the trick that if a <=0 ifindex is specified,
and no name is passed but a GROUP is passed, then we
operate on the group i.e something like:

        if (ifm->ifi_index > 0)
                dev = __dev_get_by_index(net, ifm->ifi_index);
        else {
                if (tb[IFLA_IFNAME])
                     dev = __dev_get_by_name(net, ifname);
                else if (tb[IFLA_GROUP])
                     new/get/set/del specific stuff..
                else
                   return -EINVAL;
       }


cheers,
jamal

On Mon, 2011-01-10 at 13:38 +0200, Vlad Dogaru wrote:
> Add a new type of message, IFLA_FILTERGROUP, which, if present in a
> userspace request, specifies that parameters should be changed for all
> devices in the group.
> 


