From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [patch net-next] bonding: create netlink event when bonding
 option is changed
Date: Wed, 20 Aug 2014 13:11:14 +0200
Message-ID: <20140820111114.GA8421@mikrodark.usersys.redhat.com>
References: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
 <20140819203401.GA1954@gospo.home.greyhouse.net>
 <20140819203748.GA4326@nanopsycho.orion>
 <20140819204634.GB1954@gospo.home.greyhouse.net>
 <20140820064458.GA1916@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	andy@greyhouse.net, nikolay@redhat.com, dingtianhong@huawei.com,
	sfeldma@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:34427 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbaHTLOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 07:14:14 -0400
Received: by mail-we0-f179.google.com with SMTP id u57so7687835wes.38
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2014 04:14:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140820064458.GA1916@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2014 at 08:44:58AM +0200, Jiri Pirko wrote:
>Tue, Aug 19, 2014 at 10:46:34PM CEST, gospo@cumulusnetworks.com wrote:
>>On Tue, Aug 19, 2014 at 10:37:48PM +0200, Jiri Pirko wrote:
>>> Tue, Aug 19, 2014 at 10:34:01PM CEST, gospo@cumulusnetworks.com wrote:
>>> >On Tue, Aug 19, 2014 at 04:02:12PM +0200, Jiri Pirko wrote:
...snip...
>>> >>  	if (ret)
>>> >>  		bond_opt_error_interpret(bond, opt, ret, val);
>>> >> +	else
>>> >> +		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
...snip...
>>My question was:  Is there a need for 2 netlink messages to indicate
>>that a bonding configuration change was needed when the config came over
>>netlink.  I did not see the need for 2 netlink messages in this case and
>>was asking for clarification from you.
>
>Imagine 2 applications. One is just monitoring netlink events ("ip
>mon"), the second is setting up bond via netlink. Now, the second sends
>a message to kernel, that is unicast to kernel. The first application
>does not see that message. Therefore there is need to generate the event
>message in kernel and send it back to userspace via multicast.
>That message the first application will see. And that is exactly what
>my patch is doing.

Seems fair, as there's no other way to catch those modifications, even
though they're known to the "changing" application.

Acked-by: Veaceslav Falico <vfalico@gmail.com>
