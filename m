From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next] bonding: create netlink event when bonding
 option is changed
Date: Wed, 20 Aug 2014 10:49:01 -0700
Message-ID: <20140820104901.2bbf9965@uryu.home.lan>
References: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
	<20140819203401.GA1954@gospo.home.greyhouse.net>
	<20140819203748.GA4326@nanopsycho.orion>
	<20140819204634.GB1954@gospo.home.greyhouse.net>
	<20140820064458.GA1916@nanopsycho.orion>
	<20140820140051.GC1954@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, nikolay@redhat.com, dingtianhong@huawei.com,
	sfeldma@cumulusnetworks.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:60021 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaHTRtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 13:49:09 -0400
Received: by mail-ie0-f173.google.com with SMTP id tr6so3327691ieb.32
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2014 10:49:08 -0700 (PDT)
In-Reply-To: <20140820140051.GC1954@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Aug 2014 10:00:51 -0400
Andy Gospodarek <gospo@cumulusnetworks.com> wrote:

> > >
> > >My question was:  Is there a need for 2 netlink messages to indicate
> > >that a bonding configuration change was needed when the config came over
> > >netlink.  I did not see the need for 2 netlink messages in this case and
> > >was asking for clarification from you.  
> > 
> > Imagine 2 applications. One is just monitoring netlink events ("ip
> > mon"), the second is setting up bond via netlink. Now, the second sends
> > a message to kernel, that is unicast to kernel. The first application
> > does not see that message. Therefore there is need to generate the event
> > message in kernel and send it back to userspace via multicast.
> > That message the first application will see. And that is exactly what
> > my patch is doing.  
> 
> Agreed.  Thanks for having the discussion on this.
> 
> Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>

Quagga uses socket filter to solve this problem.
The application filters out it's own route change events.
